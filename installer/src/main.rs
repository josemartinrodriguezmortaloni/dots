mod app;
mod catalog;
mod cli;
mod donut;
mod dots;
mod hooks;
mod layout;
mod link;
mod ops;
mod plan;
mod report;
mod sh;
mod theme;
mod ui;
mod worker;

use std::io::IsTerminal;

use anyhow::{Result, bail};
use ratatui::DefaultTerminal;

use crate::app::App;
use crate::catalog::MODULES;
use crate::cli::Mode;
use crate::dots::Dots;
use crate::link::Backup;
use crate::plan::Plan;

fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let mode = cli::parse(&args)?;

    dispatch(mode)
}

fn dispatch(mode: Mode) -> Result<()> {
    match mode {
        Mode::Help => {
            report::help();
            Ok(())
        }
        Mode::All => install_all(),
        Mode::Interactive => interactive(),
    }
}

fn install_all() -> Result<()> {
    let dots = Dots::from_env()?;
    let keys: Vec<&'static str> = MODULES.iter().map(|module| module.key).collect();
    let plan = Plan::build(&dots, &keys)?;
    let backup = Backup::new(dots.backup(), dots.home_root());

    let summary = worker::execute(&plan, &backup, dots.home_root(), &mut |progress| {
        report::line(&progress);
    });
    report::summary(Some(&summary));

    Ok(())
}

fn interactive() -> Result<()> {
    if !std::io::stdin().is_terminal() {
        bail!("no hay terminal interactiva: usá --all");
    }

    session(App::new(Dots::from_env()?))
}

/// El resumen se reimprime fuera de la pantalla alternativa: `restore` limpia
/// todo lo que la TUI dibujó y el conteo es justamente lo que se relee.
fn session(mut app: App) -> Result<()> {
    let mut terminal = ratatui::init();
    let outcome = drive(&mut terminal, &mut app);
    ratatui::restore();

    outcome?;
    report::summary(app.outcome.as_ref());

    Ok(())
}

fn drive(terminal: &mut DefaultTerminal, app: &mut App) -> Result<()> {
    while app.running() {
        tick(terminal, app)?;
    }

    Ok(())
}

fn tick(terminal: &mut DefaultTerminal, app: &mut App) -> Result<()> {
    terminal.draw(|frame| ui::draw(frame, app))?;

    app.step()
}
