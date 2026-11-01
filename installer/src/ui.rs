use std::path::PathBuf;

use ratatui::Frame;
use ratatui::layout::{Constraint, Layout as Split, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, Paragraph};

use crate::app::{App, Confirm, MENU, Run, Screen};
use crate::art;
use crate::catalog::MODULES;
use crate::layout;
use crate::machine::Machine;
use crate::theme::Palette;
use crate::worker::Summary;

const MAX_DISPLACED: usize = 6;
const RUNNING_HINT: &str = "instalando…";
/// Columnas de la barra que no son celdas: `[`, `] ` y el porcentaje.
const GAUGE_FRAME: u16 = 7;
/// Brillo de la tinta de la barra sin el barrido, con margen para que se vea.
const GAUGE_LIGHT: f32 = 0.7;
const MACHINE_QUESTION: &str = "¿En qué equipo se instala la configuración?";

pub fn draw(frame: &mut Frame, app: &App) {
    let areas = layout::split(frame.area(), app.art.size());

    frame.render_widget(surface(&app.palette), frame.area());
    art(frame, app, areas.art);
    body(frame, app, areas.body);
    frame.render_widget(hints(&app.screen, &app.palette), areas.footer);
}

fn surface(palette: &Palette) -> Block<'static> {
    Block::new().style(Style::new().bg(palette.background))
}

fn art(frame: &mut Frame, app: &App, area: Option<Rect>) {
    let Some(area) = area else {
        return;
    };

    let canvas = app.art.render(area.width, area.height);
    let lines: Vec<Line> = canvas
        .runs()
        .iter()
        .map(|row| shaded(row, &app.palette))
        .collect();

    frame.render_widget(Paragraph::new(lines), area);
}

fn shaded(row: &[art::Run], palette: &Palette) -> Line<'static> {
    Line::from(
        row.iter()
            .map(|run| glow(run, palette))
            .collect::<Vec<Span>>(),
    )
}

fn glow(run: &art::Run, palette: &Palette) -> Span<'static> {
    let color = palette.glow(art::tone(run.light));

    Span::styled(run.text.clone(), Style::new().fg(color))
}

fn body(frame: &mut Frame, app: &App, area: Rect) {
    match &app.screen {
        Screen::Machine { cursor } => frame.render_widget(machines(*cursor, &app.palette), area),
        Screen::Menu { cursor } => frame.render_widget(menu(*cursor, &app.palette), area),
        Screen::Select { cursor } => frame.render_widget(modules(app, *cursor), area),
        Screen::Confirm(confirm) => frame.render_widget(confirmation(confirm, &app.palette), area),
        Screen::Running(run) => running(frame, app, run, area),
        Screen::Report(summary) => frame.render_widget(report(summary, &app.palette), area),
        Screen::Done => {}
    }
}

fn machines(cursor: usize, palette: &Palette) -> Paragraph<'static> {
    let mut lines = vec![
        Line::styled(MACHINE_QUESTION, Style::new().fg(palette.foreground)),
        Line::raw(""),
    ];

    lines.extend(
        Machine::ALL
            .iter()
            .enumerate()
            .map(|(index, machine)| option(index == cursor, machine.label().to_owned(), palette)),
    );

    Paragraph::new(lines)
}

fn menu(cursor: usize, palette: &Palette) -> Paragraph<'static> {
    let lines: Vec<Line> = MENU
        .iter()
        .enumerate()
        .map(|(index, label)| option(index == cursor, (*label).to_owned(), palette))
        .collect();

    Paragraph::new(lines)
}

fn option(current: bool, label: String, palette: &Palette) -> Line<'static> {
    Line::from(vec![
        marker(current, palette),
        Span::styled(label, entry_style(current, palette)),
    ])
}

fn marker(current: bool, palette: &Palette) -> Span<'static> {
    match current {
        true => Span::styled(" ❯ ", Style::new().fg(palette.accent)),
        false => Span::raw("   "),
    }
}

fn entry_style(current: bool, palette: &Palette) -> Style {
    match current {
        true => Style::new().fg(palette.accent).add_modifier(Modifier::BOLD),
        false => Style::new().fg(palette.foreground),
    }
}

fn modules(app: &App, cursor: usize) -> Paragraph<'static> {
    let lines: Vec<Line> = (0..MODULES.len())
        .map(|index| module_line(index, cursor, app))
        .collect();

    Paragraph::new(lines)
}

fn module_line(index: usize, cursor: usize, app: &App) -> Line<'static> {
    let module = &MODULES[index];
    let on = app.picked.get(index).copied().unwrap_or(false);

    Line::from(vec![
        marker(index == cursor, &app.palette),
        checkbox(on, &app.palette),
        Span::styled(
            format!(" {:<9}", module.key),
            entry_style(index == cursor, &app.palette),
        ),
        Span::styled(
            format!("  {}", module.desc),
            Style::new().fg(app.palette.muted),
        ),
    ])
}

fn checkbox(on: bool, palette: &Palette) -> Span<'static> {
    match on {
        true => Span::styled("●", Style::new().fg(palette.green)),
        false => Span::styled("○", Style::new().fg(palette.muted)),
    }
}

fn confirmation(confirm: &Confirm, palette: &Palette) -> Paragraph<'static> {
    let mut lines = vec![
        Line::styled(
            format!("{} módulo(s) a instalar", confirm.plan.len()),
            Style::new().fg(palette.foreground),
        ),
        Line::raw(""),
        Line::styled(
            headline(confirm.displaced.len()),
            Style::new().fg(palette.yellow),
        ),
    ];

    lines.extend(displaced_lines(&confirm.displaced, palette));
    lines.push(Line::raw(""));
    lines.push(choice(confirm.accept, palette));

    Paragraph::new(lines)
}

fn headline(count: usize) -> String {
    match count {
        0 => "Ningún archivo existente se mueve".to_owned(),
        rest => format!("{rest} archivo(s) se mueven al backup antes de enlazar"),
    }
}

fn displaced_lines(paths: &[PathBuf], palette: &Palette) -> Vec<Line<'static>> {
    let mut lines: Vec<Line> = paths
        .iter()
        .take(MAX_DISPLACED)
        .map(|path| {
            Line::styled(
                format!("  {}", path.display()),
                Style::new().fg(palette.muted),
            )
        })
        .collect();

    lines.extend(overflow(paths.len(), palette));

    lines
}

fn overflow(total: usize, palette: &Palette) -> Option<Line<'static>> {
    let rest = total.saturating_sub(MAX_DISPLACED);

    (rest > 0).then(|| Line::styled(format!("  … y {rest} más"), Style::new().fg(palette.muted)))
}

fn choice(accept: bool, palette: &Palette) -> Line<'static> {
    Line::from(vec![
        pill("  Sí  ", accept, palette),
        Span::raw("  "),
        pill("  No  ", !accept, palette),
    ])
}

fn pill(label: &'static str, active: bool, palette: &Palette) -> Span<'static> {
    match active {
        true => Span::styled(
            label,
            Style::new()
                .fg(palette.background)
                .bg(palette.accent)
                .add_modifier(Modifier::BOLD),
        ),
        false => Span::styled(label, Style::new().fg(palette.muted)),
    }
}

fn running(frame: &mut Frame, app: &App, run: &Run, area: Rect) {
    let palette = &app.palette;
    let [label, bar, notes] = Split::vertical([
        Constraint::Length(1),
        Constraint::Length(1),
        Constraint::Fill(1),
    ])
    .areas(area);

    frame.render_widget(current(run, palette), label);
    frame.render_widget(Paragraph::new(gauge(run, app, bar.width)), bar);
    frame.render_widget(progress_notes(run, palette), notes);
}

/// El aviso va pegado a la barra, no en el pie: entre los dos hay una banda
/// vacía que lo dejaba a media pantalla de distancia.
fn progress_notes(run: &Run, palette: &Palette) -> Paragraph<'static> {
    let mut lines = vec![Line::styled(RUNNING_HINT, Style::new().fg(palette.muted))];
    lines.extend(failure_line(run, palette));

    Paragraph::new(lines)
}

fn failure_line(run: &Run, palette: &Palette) -> Option<Line<'static>> {
    (run.failures > 0).then(|| {
        Line::styled(
            format!("{} error(es)", run.failures),
            Style::new().fg(palette.red),
        )
    })
}

fn current(run: &Run, palette: &Palette) -> Paragraph<'static> {
    Paragraph::new(format!(
        "[{}/{}] {}",
        run.index + 1,
        run.total.max(1),
        run.key
    ))
    .style(Style::new().fg(palette.foreground))
}

/// La barra usa la rampa de tinta del arte: cada celda tiene la densidad de
/// lo que ya avanzó sobre ella, así que el borde muestra la fracción con
/// glifos intermedios. El barrido de brillo del arte también la recorre.
fn gauge(run: &Run, app: &App, width: u16) -> Line<'static> {
    let muted = Style::new().fg(app.palette.muted);
    let cells = usize::from(width.saturating_sub(GAUGE_FRAME));
    let filled = run.ratio() as f32 * cells as f32;

    let mut spans = vec![Span::styled("[", muted)];
    spans.extend((0..cells).map(|i| gauge_cell(filled - i as f32, i as f32 / cells as f32, app)));
    spans.push(Span::styled("] ", muted));
    spans.push(Span::styled(
        format!("{:>3.0}%", run.ratio() * 100.0),
        Style::new()
            .fg(app.palette.accent)
            .add_modifier(Modifier::BOLD),
    ));

    Line::from(spans)
}

/// Una celda sin tinta muestra el riel en `muted`.
fn gauge_cell(ink: f32, position: f32, app: &App) -> Span<'static> {
    let glyph = art::glyph(ink);
    let light = (GAUGE_LIGHT + app.art.shine(position)).min(1.0);

    match glyph {
        b' ' => Span::styled(".", Style::new().fg(app.palette.muted)),
        _ => Span::styled(solid(glyph), Style::new().fg(app.palette.glow(light))),
    }
}

/// La celda llena es un bloque sólido; el borde conserva la rampa del arte.
fn solid(glyph: u8) -> String {
    match glyph {
        b'@' => String::from('#'),
        _ => char::from(glyph).to_string(),
    }
}

fn report(summary: &Summary, palette: &Palette) -> Paragraph<'static> {
    let mut lines = vec![
        Line::styled(
            format!(
                "{} enlace(s) creados · {} respaldado(s)",
                summary.linked, summary.backed
            ),
            Style::new().fg(palette.green),
        ),
        Line::styled(
            format!("backup → {}", summary.backup.display()),
            Style::new().fg(palette.muted),
        ),
        Line::raw(""),
    ];

    lines.extend(listed(&summary.failures, palette.red));
    lines.extend(listed(&summary.notes, palette.muted));

    Paragraph::new(lines)
}

fn listed(items: &[String], color: Color) -> Vec<Line<'static>> {
    items
        .iter()
        .map(|item| Line::styled(item.clone(), Style::new().fg(color)))
        .collect()
}

fn hints(screen: &Screen, palette: &Palette) -> Paragraph<'static> {
    Paragraph::new(hint_text(screen)).style(Style::new().fg(palette.muted))
}

fn hint_text(screen: &Screen) -> &'static str {
    match screen {
        Screen::Machine { .. } | Screen::Menu { .. } => "↑/↓ mover · enter elegir · q salir",
        Screen::Select { .. } => {
            "↑/↓ mover · espacio marcar · a todos · n ninguno · enter seguir · esc volver"
        }
        Screen::Confirm(_) => "←/→ elegir · s sí · n no · enter confirmar · esc volver",
        Screen::Running(_) => "",
        _ => "cualquier tecla para salir",
    }
}
