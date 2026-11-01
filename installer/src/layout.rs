use ratatui::layout::{Constraint, Layout, Rect, Size};

/// Ancho a partir del cual entran dos columnas sin apretar la lista.
const WIDE: u16 = 100;
/// Alto a partir del cual el arte entra arriba en una sola columna.
const TALL: u16 = 34;
/// Alto de la banda que comparten el arte y el texto en dos columnas. Fijarlo
/// es lo que permite centrar las dos a la vez: con alturas distintas, una
/// arranca arriba y la otra queda a mitad de pantalla.
const BLOCK: u16 = 24;
const ART_WIDTH: u16 = 44;
const ART_HEIGHT: u16 = 12;
const GAP: u16 = 3;
/// Ancho mínimo que la lista conserva junto al arte.
const CONTENT: u16 = WIDE - ART_WIDTH - GAP;
const FOOTER: u16 = 2;
const MARGIN: u16 = 2;

pub struct Areas {
    pub art: Option<Rect>,
    pub body: Rect,
    pub footer: Rect,
}

/// El recorte silencioso es un defecto: en un terminal angosto la lista de
/// módulos tiene prioridad sobre el arte, que se achica o desaparece.
pub fn split(area: Rect, art: Size) -> Areas {
    let inner = area.inner(ratatui::layout::Margin::new(MARGIN, 1));

    match inner.width >= WIDE {
        true => wide(inner, art),
        false => rows(inner),
    }
}

/// Con lugar para el arte a tamaño original, su columna usa todo el alto y
/// solo el texto queda en la banda. Si no, los dos comparten la banda.
fn wide(area: Rect, art: Size) -> Areas {
    match native(area, art) {
        true => columns(area, art.width),
        false => columns(band(area), ART_WIDTH),
    }
}

fn native(area: Rect, art: Size) -> bool {
    area.height >= art.height && area.width >= art.width + GAP + CONTENT
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

fn columns(area: Rect, width: u16) -> Areas {
    let [art, _, content] = Layout::horizontal([
        Constraint::Length(width),
        Constraint::Length(GAP),
        Constraint::Fill(1),
    ])
    .areas(area);

    Areas {
        art: Some(art),
        ..stack(band(content))
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
    let [body, footer] =
        Layout::vertical([Constraint::Fill(1), Constraint::Length(FOOTER)]).areas(area);

    Areas {
        art: None,
        body,
        footer,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const ART: Size = Size::new(64, 59);

    fn art_of(width: u16, height: u16) -> Rect {
        split(Rect::new(0, 0, width, height), ART)
            .art
            .unwrap_or_default()
    }

    #[test]
    fn a_tall_terminal_gives_the_art_its_original_size() {
        let art = art_of(140, 64);

        assert_eq!(art.width, ART.width);
        assert!(art.height >= ART.height);
    }

    #[test]
    fn a_short_terminal_shares_the_band() {
        let art = art_of(140, 40);

        assert_eq!((art.width, art.height), (ART_WIDTH, BLOCK));
    }

    #[test]
    fn the_text_stays_in_the_band_next_to_the_full_art() {
        let areas = split(Rect::new(0, 0, 140, 64), ART);

        assert!(areas.body.height + areas.footer.height <= BLOCK);
    }
}
