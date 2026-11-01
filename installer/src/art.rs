use std::f32::consts::TAU;

use ratatui::layout::Size;

const SOURCE: &str = include_str!("art.txt");
/// Rampa de densidad de tinta del arte fuente. El índice dividido por el
/// último índice es la densidad de la celda.
const RAMP: &[u8] = b" .:-=+*#%@";
/// Pasos de brillo que distingue el color. Más pasos parten cada fila en más
/// `Span` por cuadro.
const LIGHTS: u8 = 16;

/// Un ciclo completo dura 240 cuadros: unos 8 s a 33 ms por cuadro. Toda
/// frecuencia es un múltiplo entero de la fase, así el ciclo cierra sin saltos.
const STEP: f32 = TAU / 240.0;
/// Amplitud del balanceo en columnas de la fuente, en la fila superior. La
/// base queda quieta y la punta se mueve.
const SWAY: f32 = 2.0;
/// Desfase del balanceo por fila de la fuente: la onda baja por la figura.
const WAVE: f32 = 0.06;
/// Peso del resplandor que la tinta irradia a las celdas vecinas.
const HALO: f32 = 0.16;
/// Brillo extra de la banda que barre la figura en diagonal.
const SHINE: f32 = 0.45;
const SHINE_WIDTH: f32 = 0.09;
/// Brillo mínimo de un glifo, para que la tinta tenue no se funda con el fondo.
const FLOOR: f32 = 0.3;
/// Brillo de la tinta más densa sin resplandor ni barrido. El margen hasta 1
/// es lo que hace visibles a los dos.
const PEAK: f32 = 0.7;

pub struct Art {
    source: Grid,
    phase: f32,
}

pub struct Run {
    pub light: u8,
    pub text: String,
}

pub struct Canvas {
    cols: usize,
    cells: Vec<Cell>,
}

#[derive(Clone, Copy, PartialEq)]
struct Cell {
    glyph: u8,
    light: u8,
}

/// Densidad de tinta por celda, de 0 a 1.
struct Grid {
    cols: usize,
    rows: usize,
    ink: Vec<f32>,
}

/// Dónde cae el arte reducido dentro del área: el arte conserva su
/// proporción y queda centrado.
struct Fit {
    scale: f32,
    cols: usize,
    rows: usize,
    left: usize,
    top: usize,
}

impl Cell {
    const EMPTY: Self = Self {
        glyph: b' ',
        light: 0,
    };
}

impl Art {
    pub fn new() -> Self {
        Self {
            source: Grid::parse(SOURCE),
            phase: 0.0,
        }
    }

    /// Tamaño original del dibujo, sin márgenes.
    pub fn size(&self) -> Size {
        Size::new(self.source.cols as u16, self.source.rows as u16)
    }

    pub fn tick(&mut self) {
        self.phase = (self.phase + STEP) % TAU;
    }

    pub fn render(&self, cols: u16, rows: u16) -> Canvas {
        let mut canvas = Canvas::blank(usize::from(cols), usize::from(rows));
        let fit = Fit::new(&self.source, canvas.cols, usize::from(rows));
        let ink = self.shrink(&fit);
        let halo = ink.blur();

        for y in 0..fit.rows {
            for x in 0..fit.cols {
                let cell = self.cell(ink.at(x, y), halo.at(x, y), fit.diagonal(x, y));
                canvas.put(fit.left + x, fit.top + y, cell);
            }
        }

        canvas
    }

    /// Lleva la fuente al tamaño del área, corrida por el balanceo de cada
    /// fila. A tamaño original copia cada celda tal cual. Reducida, cada celda
    /// es el promedio de su bloque: la raíz devuelve el contraste que el
    /// promedio le quita a los trazos finos (un `@` en 3×3 promedia 0.33).
    fn shrink(&self, fit: &Fit) -> Grid {
        let mut grid = Grid::blank(fit.cols, fit.rows);

        for y in 0..fit.rows {
            for x in 0..fit.cols {
                grid.ink[y * fit.cols + x] = self.sample(fit, x, y);
            }
        }

        grid
    }

    fn sample(&self, fit: &Fit, x: usize, y: usize) -> f32 {
        let size = 1.0 / fit.scale;
        let top = y as f32 * size;
        let left = x as f32 * size + self.sway(top);

        match fit.scale < 1.0 {
            true => self.source.mean(left, top, size).sqrt(),
            false => self.source.peek(left.round() as isize, top as isize),
        }
    }

    fn sway(&self, row: f32) -> f32 {
        let reach = 1.0 - row / self.source.rows as f32;

        SWAY * reach * (self.phase + row * WAVE).sin()
    }

    /// El halo respira al doble de la frecuencia del balanceo. En el pico,
    /// las celdas vacías junto a la tinta encienden un glifo tenue.
    fn cell(&self, ink: f32, halo: f32, diagonal: f32) -> Cell {
        let glow = halo * HALO * (0.5 + 0.5 * (2.0 * self.phase).sin());
        let glyph = glyph(ink.max(glow));
        let light = FLOOR + ink * (PEAK - FLOOR) + glow + self.shine(diagonal);

        lit(glyph, light)
    }

    /// Una banda gaussiana que cruza la figura una vez por ciclo. Arranca y
    /// termina fuera de la figura, así el reinicio de la fase no se ve.
    pub fn shine(&self, diagonal: f32) -> f32 {
        let center = -0.3 + 1.6 * self.phase / TAU;
        let distance = (diagonal - center) / SHINE_WIDTH;

        SHINE * (-distance * distance).exp()
    }
}

impl Default for Art {
    fn default() -> Self {
        Self::new()
    }
}

impl Grid {
    fn blank(cols: usize, rows: usize) -> Self {
        Self {
            cols,
            rows,
            ink: vec![0.0; cols * rows],
        }
    }

    /// Recorta las filas vacías de arriba y de abajo y la sangría común: el
    /// archivo trae el dibujo con márgenes que el área no tiene por qué pagar.
    fn parse(text: &str) -> Self {
        let lines: Vec<&str> = text.lines().collect();
        let first = lines.iter().position(|l| !blank(l)).unwrap_or(0);
        let last = lines.iter().rposition(|l| !blank(l)).map_or(0, |i| i + 1);
        let body = &lines[first..last.max(first)];

        let left = body
            .iter()
            .filter(|l| !blank(l))
            .map(|l| indent(l))
            .min()
            .unwrap_or(0);
        let width = body.iter().map(|l| l.len()).max().unwrap_or(0);
        let mut grid = Self::blank(width.saturating_sub(left), body.len());

        for (y, line) in body.iter().enumerate() {
            grid.fill_row(y, line.as_bytes().get(left..).unwrap_or_default());
        }

        grid
    }

    fn fill_row(&mut self, y: usize, line: &[u8]) {
        for (x, &byte) in line.iter().enumerate() {
            self.ink[y * self.cols + x] = density(byte);
        }
    }

    fn at(&self, x: usize, y: usize) -> f32 {
        self.peek(x as isize, y as isize)
    }

    /// Fuera de la grilla no hay tinta: el balanceo y el desenfoque leen
    /// celdas más allá del borde.
    fn peek(&self, x: isize, y: isize) -> f32 {
        let inside = (0..self.cols as isize).contains(&x) && (0..self.rows as isize).contains(&y);

        match inside {
            true => self.ink[y as usize * self.cols + x as usize],
            false => 0.0,
        }
    }

    fn mean(&self, left: f32, top: f32, size: f32) -> f32 {
        let columns = left.floor() as isize..(left + size).ceil() as isize;
        let rows = top.floor() as isize..(top + size).ceil() as isize;
        let count = columns.len() * rows.len();

        let sum: f32 = rows
            .flat_map(|y| columns.clone().map(move |x| (x, y)))
            .map(|(x, y)| self.peek(x, y))
            .sum();

        sum / count.max(1) as f32
    }

    /// Promedio de 3×3 alrededor de cada celda: cuánta tinta tiene cerca.
    fn blur(&self) -> Self {
        let mut halo = Self::blank(self.cols, self.rows);

        for y in 0..self.rows {
            for x in 0..self.cols {
                halo.ink[y * self.cols + x] = self.mean(x as f32 - 1.0, y as f32 - 1.0, 3.0);
            }
        }

        halo
    }
}

impl Fit {
    /// El arte nunca se agranda: ampliar un dibujo ASCII solo repite glifos.
    fn new(source: &Grid, cols: usize, rows: usize) -> Self {
        let scale = (cols as f32 / source.cols as f32)
            .min(rows as f32 / source.rows as f32)
            .min(1.0);
        let width = (source.cols as f32 * scale) as usize;
        let height = (source.rows as f32 * scale) as usize;

        Self {
            scale,
            cols: width,
            rows: height,
            left: (cols - width) / 2,
            top: (rows - height) / 2,
        }
    }

    /// Posición de la celda sobre la diagonal de la figura, de 0 a 1.
    fn diagonal(&self, x: usize, y: usize) -> f32 {
        let across = x as f32 / self.cols.max(1) as f32;
        let down = y as f32 / self.rows.max(1) as f32;

        (across + down) / 2.0
    }
}

impl Canvas {
    fn blank(cols: usize, rows: usize) -> Self {
        Self {
            cols,
            cells: vec![Cell::EMPTY; cols * rows],
        }
    }

    fn put(&mut self, x: usize, y: usize, cell: Cell) {
        if let Some(slot) = self.cells.get_mut(y * self.cols + x) {
            *slot = cell;
        }
    }

    /// Una fila por línea, con las celdas iguales agrupadas: un `Span` por
    /// celda costaría cientos de asignaciones por cuadro.
    pub fn runs(&self) -> Vec<Vec<Run>> {
        self.cells.chunks(self.cols.max(1)).map(group).collect()
    }
}

/// Intensidad del brillo, de 0 a 1, que `Palette::glow` convierte en color.
pub fn tone(light: u8) -> f32 {
    f32::from(light) / f32::from(LIGHTS)
}

fn group(line: &[Cell]) -> Vec<Run> {
    let mut runs: Vec<(Cell, String)> = Vec::new();

    for &cell in line {
        push(&mut runs, cell);
    }

    runs.into_iter()
        .map(|(cell, text)| Run {
            light: cell.light,
            text,
        })
        .collect()
}

fn push(runs: &mut Vec<(Cell, String)>, cell: Cell) {
    match runs.last_mut().filter(|(last, _)| *last == cell) {
        Some((_, text)) => text.push(char::from(cell.glyph)),
        None => runs.push((cell, String::from(char::from(cell.glyph)))),
    }
}

/// Un glifo vacío no lleva color: así los espacios se agrupan en un solo `Run`.
fn lit(glyph: u8, light: f32) -> Cell {
    match glyph {
        b' ' => Cell::EMPTY,
        _ => Cell {
            glyph,
            light: (light.clamp(0.0, 1.0) * f32::from(LIGHTS)).round() as u8,
        },
    }
}

pub fn glyph(ink: f32) -> u8 {
    let last = (RAMP.len() - 1) as f32;

    RAMP[(ink.clamp(0.0, 1.0) * last).round() as usize]
}

fn density(byte: u8) -> f32 {
    let last = (RAMP.len() - 1) as f32;

    RAMP.iter()
        .position(|&b| b == byte)
        .map_or(0.0, |i| i as f32 / last)
}

fn blank(line: &str) -> bool {
    line.trim().is_empty()
}

fn indent(line: &str) -> usize {
    line.len() - line.trim_start().len()
}

#[cfg(test)]
mod tests {
    use super::*;

    const COLS: u16 = 44;
    const ROWS: u16 = 24;

    fn inked(canvas: &Canvas) -> Vec<usize> {
        let cols = canvas.cols;

        (0..canvas.cells.len())
            .filter(|i| canvas.cells[*i].glyph != b' ')
            .map(|i| i % cols)
            .collect()
    }

    #[test]
    fn parsing_drops_the_blank_margins() {
        let grid = Grid::parse(SOURCE);

        assert_eq!(grid.rows, 59);
        assert!(
            (0..grid.cols).any(|x| grid.at(x, 0) > 0.0),
            "primera fila sin tinta"
        );
        assert!(
            (0..grid.rows).any(|y| grid.at(0, y) > 0.0),
            "primera columna sin tinta"
        );
    }

    #[test]
    fn the_art_fills_the_height_and_stays_centered() {
        let canvas = Art::new().render(COLS, ROWS);
        let columns = inked(&canvas);
        let rows: Vec<usize> = canvas.runs().iter().map(|r| r.len()).collect();

        assert_eq!(rows.len(), usize::from(ROWS));
        assert!(
            columns.iter().min().is_some_and(|c| *c > 0),
            "el arte toca el borde izquierdo"
        );
        assert!(
            columns
                .iter()
                .max()
                .is_some_and(|c| *c < usize::from(COLS) - 1)
        );
    }

    #[test]
    fn at_full_size_the_glyphs_match_the_source() {
        let art = Art::new();
        let size = art.size();
        let canvas = art.render(size.width, size.height);
        let grid = Grid::parse(SOURCE);
        // Fase 0: la fila superior no se corre y el halo está en su mínimo.
        let top: String = canvas.cells[..grid.cols]
            .iter()
            .map(|c| char::from(c.glyph))
            .collect();
        let source: String = (0..grid.cols)
            .map(|x| char::from(glyph(grid.at(x, 0))))
            .collect();

        assert_eq!(top, source);
    }

    #[test]
    fn an_empty_area_draws_nothing() {
        assert!(inked(&Art::new().render(0, 0)).is_empty());
        assert!(inked(&Art::new().render(COLS, 0)).is_empty());
    }

    #[test]
    fn ticking_moves_the_art() {
        let mut art = Art::new();
        let before = art.render(COLS, ROWS).cells;

        for _ in 0..30 {
            art.tick();
        }

        assert!(before != art.render(COLS, ROWS).cells);
    }

    #[test]
    fn the_shine_brightens_only_near_its_band() {
        let mut art = Art::new();
        art.phase = TAU * 0.3 / 1.6;

        assert!(art.shine(0.0) > SHINE * 0.99);
        assert!(art.shine(0.5) < 0.01);
    }

    #[test]
    fn the_halo_lights_empty_cells_next_to_ink() {
        let mut art = Art::new();
        art.phase = TAU / 8.0;

        assert_eq!(art.cell(0.0, 0.0, 1.0).glyph, b' ');
        assert_eq!(art.cell(0.0, 1.0, 1.0).glyph, b'.');
    }
}
