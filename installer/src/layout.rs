use ratatui::layout::{Constraint, Layout, Rect};

/// Ancho a partir del cual entran dos columnas sin apretar la lista.
const WIDE: u16 = 100;
/// Alto a partir del cual el donut entra arriba en una sola columna.
const TALL: u16 = 34;
/// Alto de la banda que comparten el arte y el texto en dos columnas. Fijarlo
/// es lo que permite centrar las dos a la vez: con alturas distintas, una
/// arranca arriba y la otra queda a mitad de pantalla.
const BLOCK: u16 = 24;
const ART_WIDTH: u16 = 44;
const ART_HEIGHT: u16 = 12;
const GAP: u16 = 3;
const HEADER: u16 = 6;
const FOOTER: u16 = 2;
const MARGIN: u16 = 2;

pub struct Areas {
    pub art: Option<Rect>,
    pub header: Rect,
    pub body: Rect,
    pub footer: Rect,
}

/// El recorte silencioso es un defecto: en un terminal angosto la lista de
/// módulos tiene prioridad sobre el donut, que se achica o desaparece.
pub fn split(area: Rect) -> Areas {
    let inner = area.inner(ratatui::layout::Margin::new(MARGIN, 1));

    match inner.width >= WIDE {
        true => columns(band(inner)),
        false => rows(inner),
    }
}

/// La banda centrada verticalmente que ocupan las dos columnas.
fn band(area: Rect) -> Rect {
    let [_, band, _] = Layout::vertical([
        Constraint::Fill(1),
        Constraint::Max(BLOCK),
        Constraint::Fill(1),
    ])
    .areas(area);

    band
}

fn columns(area: Rect) -> Areas {
    let [art, _, content] = Layout::horizontal([
        Constraint::Length(ART_WIDTH),
        Constraint::Length(GAP),
        Constraint::Fill(1),
    ])
    .areas(area);

    Areas {
        art: Some(art),
        ..stack(content)
    }
}

fn rows(area: Rect) -> Areas {
    match area.height >= TALL {
        true => stacked_art(area),
        false => stack(area),
    }
}

fn stacked_art(area: Rect) -> Areas {
    let [art, content] =
        Layout::vertical([Constraint::Length(ART_HEIGHT), Constraint::Fill(1)]).areas(area);

    Areas {
        art: Some(art),
        ..stack(content)
    }
}

fn stack(area: Rect) -> Areas {
    let [header, body, footer] = Layout::vertical([
        Constraint::Length(HEADER),
        Constraint::Fill(1),
        Constraint::Length(FOOTER),
    ])
    .areas(area);

    Areas {
        art: None,
        header,
        body,
        footer,
    }
}
