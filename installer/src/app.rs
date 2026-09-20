use std::path::PathBuf;
use std::sync::mpsc::Receiver;
use std::time::Duration;

use anyhow::Result;
use ratatui::crossterm::event::{self, Event, KeyCode, KeyEvent, KeyEventKind, KeyModifiers};

use crate::catalog::MODULES;
use crate::donut::Donut;
use crate::dots::Dots;
use crate::link::Backup;
use crate::plan::Plan;
use crate::theme::{self, Palette};
use crate::worker::{self, Progress, Summary};

const FRAME: Duration = Duration::from_millis(33);
/// Ctrl-C en modo raw llega como una tecla más. Se traduce a un código que
/// ninguna pantalla usa, para que la cancelación viva en un solo lugar.
const ABORT: KeyCode = KeyCode::Null;

pub const MENU: [&str; 3] = ["Instalar todos los módulos", "Elegir módulos", "Cancelar"];

pub enum Screen {
    Menu { cursor: usize },
    Select { cursor: usize },
    Confirm(Confirm),
    Running(Run),
    Report(Summary),
    Done,
}

pub struct Confirm {
    pub plan: Plan,
    pub displaced: Vec<PathBuf>,
    pub accept: bool,
}

pub struct Run {
    events: Receiver<Progress>,
    pub key: &'static str,
    pub index: usize,
    pub total: usize,
    pub failures: usize,
}

impl Run {
    pub fn ratio(&self) -> f64 {
        match self.total {
            0 => 1.0,
            total => (self.index as f64 / total as f64).clamp(0.0, 1.0),
        }
    }

    fn begin(&mut self, index: usize, total: usize, key: &'static str) {
        self.index = index;
        self.total = total;
        self.key = key;
    }
}

pub struct App {
    pub screen: Screen,
    pub donut: Donut,
    pub palette: Palette,
    pub picked: Vec<bool>,
    pub outcome: Option<Summary>,
    dots: Dots,
}

impl App {
    pub fn new(dots: Dots) -> Self {
        let palette = theme::load(&dots);

        Self {
            screen: Screen::Menu { cursor: 0 },
            donut: Donut::new(),
            palette,
            picked: vec![true; MODULES.len()],
            outcome: None,
            dots,
        }
    }

    pub fn running(&self) -> bool {
        !matches!(self.screen, Screen::Done)
    }

    pub fn step(&mut self) -> Result<()> {
        self.donut.spin();

        let screen = std::mem::replace(&mut self.screen, Screen::Done);
        self.screen = self.advance(screen)?;

        Ok(())
    }

    /// Mientras el hilo de trabajo escribe, el teclado no puede cortar la
    /// corrida: abortar a mitad dejaría el árbol de enlaces por la mitad.
    fn advance(&mut self, screen: Screen) -> Result<Screen> {
        let key = poll_key()?;

        match screen {
            Screen::Running(run) => Ok(self.pump(run)),
            other => self.interact(other, key),
        }
    }

    fn interact(&mut self, screen: Screen, key: Option<KeyCode>) -> Result<Screen> {
        if key == Some(ABORT) {
            return Ok(Screen::Done);
        }

        match screen {
            Screen::Menu { cursor } => self.menu(cursor, key),
            Screen::Select { cursor } => self.select(cursor, key),
            Screen::Confirm(confirm) => self.confirm(confirm, key),
            other => Ok(dismiss(other, key)),
        }
    }

    fn menu(&mut self, cursor: usize, key: Option<KeyCode>) -> Result<Screen> {
        let Some(code) = key else {
            return Ok(Screen::Menu { cursor });
        };

        match code {
            KeyCode::Enter => self.choose(cursor),
            KeyCode::Esc | KeyCode::Char('q') => Ok(Screen::Done),
            other => Ok(Screen::Menu {
                cursor: moved(cursor, MENU.len(), other),
            }),
        }
    }

    fn choose(&mut self, cursor: usize) -> Result<Screen> {
        match cursor {
            0 => self.pick_all(),
            1 => Ok(Screen::Select { cursor: 0 }),
            _ => Ok(Screen::Done),
        }
    }

    fn pick_all(&mut self) -> Result<Screen> {
        self.picked.fill(true);

        self.to_confirm()
    }

    fn select(&mut self, cursor: usize, key: Option<KeyCode>) -> Result<Screen> {
        let Some(code) = key else {
            return Ok(Screen::Select { cursor });
        };

        match code {
            KeyCode::Enter => self.to_confirm(),
            KeyCode::Esc | KeyCode::Char('q') => Ok(Screen::Menu { cursor: 0 }),
            other => Ok(Screen::Select {
                cursor: self.edit(cursor, other),
            }),
        }
    }

    fn edit(&mut self, cursor: usize, code: KeyCode) -> usize {
        match code {
            KeyCode::Char(' ') => self.toggle(cursor),
            KeyCode::Char('a') => self.set_all(true),
            KeyCode::Char('n') => self.set_all(false),
            other => moved(cursor, MODULES.len(), other),
        }
    }

    fn toggle(&mut self, cursor: usize) -> usize {
        let Some(slot) = self.picked.get_mut(cursor) else {
            return cursor;
        };

        *slot = !*slot;

        cursor
    }

    fn set_all(&mut self, on: bool) -> usize {
        self.picked.fill(on);

        0
    }

    fn to_confirm(&self) -> Result<Screen> {
        let plan = Plan::build(&self.dots, &self.keys())?;
        let displaced = plan.displaced();

        Ok(Screen::Confirm(Confirm {
            plan,
            displaced,
            accept: true,
        }))
    }

    pub fn keys(&self) -> Vec<&'static str> {
        MODULES
            .iter()
            .zip(&self.picked)
            .filter(|(_, on)| **on)
            .map(|(module, _)| module.key)
            .collect()
    }

    fn confirm(&mut self, confirm: Confirm, key: Option<KeyCode>) -> Result<Screen> {
        let Some(code) = key else {
            return Ok(Screen::Confirm(confirm));
        };

        match code {
            KeyCode::Enter => Ok(self.commit(confirm)),
            KeyCode::Esc | KeyCode::Char('q') => Ok(Screen::Menu { cursor: 0 }),
            other => Ok(Screen::Confirm(toggled(confirm, other))),
        }
    }

    fn commit(&mut self, confirm: Confirm) -> Screen {
        match confirm.accept {
            true => self.start(confirm.plan),
            false => Screen::Menu { cursor: 0 },
        }
    }

    fn start(&self, plan: Plan) -> Screen {
        let backup = Backup::new(self.dots.backup(), self.dots.home_root());
        let total = plan.len();
        let events = worker::spawn(plan, backup, self.dots.home_root().to_owned());

        Screen::Running(Run {
            events,
            key: "",
            index: 0,
            total,
            failures: 0,
        })
    }

    fn pump(&mut self, mut run: Run) -> Screen {
        while let Ok(progress) = run.events.try_recv() {
            self.absorb(&mut run, progress);
        }

        self.settle(run)
    }

    fn absorb(&mut self, run: &mut Run, progress: Progress) {
        match progress {
            Progress::Started { index, total, key } => run.begin(index, total, key),
            Progress::Failed { .. } => run.failures += 1,
            Progress::Finished(summary) => self.outcome = Some(summary),
        }
    }

    fn settle(&self, run: Run) -> Screen {
        match self.outcome.clone() {
            Some(summary) => Screen::Report(summary),
            None => Screen::Running(run),
        }
    }
}

fn dismiss(screen: Screen, key: Option<KeyCode>) -> Screen {
    match key {
        Some(_) => Screen::Done,
        None => screen,
    }
}

fn toggled(mut confirm: Confirm, code: KeyCode) -> Confirm {
    confirm.accept = accepts(confirm.accept, code);

    confirm
}

fn accepts(current: bool, code: KeyCode) -> bool {
    match code {
        KeyCode::Char('s') | KeyCode::Char('y') => true,
        KeyCode::Char('n') => false,
        KeyCode::Left | KeyCode::Right | KeyCode::Tab => !current,
        _ => current,
    }
}

fn moved(cursor: usize, len: usize, code: KeyCode) -> usize {
    match code {
        KeyCode::Up | KeyCode::Char('k') => (cursor + len - 1) % len,
        KeyCode::Down | KeyCode::Char('j') => (cursor + 1) % len,
        _ => cursor,
    }
}

fn poll_key() -> Result<Option<KeyCode>> {
    if !event::poll(FRAME)? {
        return Ok(None);
    }

    Ok(pressed(event::read()?))
}

fn pressed(event: Event) -> Option<KeyCode> {
    let Event::Key(key) = event else {
        return None;
    };

    (key.kind == KeyEventKind::Press).then(|| code_of(&key))
}

fn code_of(key: &KeyEvent) -> KeyCode {
    match is_ctrl_c(key) {
        true => ABORT,
        false => key.code,
    }
}

fn is_ctrl_c(key: &KeyEvent) -> bool {
    key.code == KeyCode::Char('c') && key.modifiers.contains(KeyModifiers::CONTROL)
}
