use std::f32::consts::TAU;

/// Rampa de luminancia. El índice dentro de la rampa es también la intensidad
/// que `Palette::glow` convierte en color.
const RAMP: &[u8] = b".,-~:;=!*#$@";
const EMPTY: u8 = u8::MAX;

const TUBE: f32 = 1.0;
const RING: f32 = 2.0;
const DEPTH: f32 = 5.0;
const THETA_STEPS: u16 = 90;
const PHI_STEPS: u16 = 314;
const SPIN_A: f32 = 0.045;
const SPIN_B: f32 = 0.023;
/// Con los dos ángulos en cero el toro se ve de canto y el primer cuadro es
/// una banda plana. Arranca ya inclinado.
const TILT_A: f32 = 1.0;
const TILT_B: f32 = 0.5;
/// Una celda de terminal mide el doble de alto que de ancho.
const CELL_ASPECT: f32 = 2.0;

pub struct Donut {
    pitch: f32,
    yaw: f32,
}

pub struct Run {
    pub level: u8,
    pub text: String,
}

struct Dot {
    col: f32,
    row: f32,
    depth: f32,
    level: u8,
}

pub struct Canvas {
    cols: usize,
    rows: usize,
    cells: Vec<u8>,
    depth: Vec<f32>,
}

impl Donut {
    pub fn new() -> Self {
        Self {
            pitch: TILT_A,
            yaw: TILT_B,
        }
    }

    pub fn spin(&mut self) {
        self.pitch = (self.pitch + SPIN_A) % TAU;
        self.yaw = (self.yaw + SPIN_B) % TAU;
    }

    pub fn render(&self, cols: u16, rows: u16) -> Canvas {
        let mut canvas = Canvas::blank(cols, rows);

        for i in 0..THETA_STEPS {
            for j in 0..PHI_STEPS {
                let dot = self.dot(angle(i, THETA_STEPS), angle(j, PHI_STEPS), &canvas);
                canvas.plot(dot);
            }
        }

        canvas
    }

    /// Proyección estándar del toro: el punto del tubo se rota en dos ejes y se
    /// divide por su profundidad. La luminancia es el producto punto con la luz.
    fn dot(&self, theta: f32, phi: f32, canvas: &Canvas) -> Option<Dot> {
        let (sin_t, cos_t) = theta.sin_cos();
        let (sin_p, cos_p) = phi.sin_cos();
        let (sin_a, cos_a) = self.pitch.sin_cos();
        let (sin_b, cos_b) = self.yaw.sin_cos();

        let ring = RING + TUBE * cos_t;
        let tube = TUBE * sin_t;

        let x = ring * (cos_b * cos_p + sin_a * sin_b * sin_p) - tube * cos_a * sin_b;
        let y = ring * (sin_b * cos_p - sin_a * cos_b * sin_p) + tube * cos_a * cos_b;
        let inverse_depth = 1.0 / (DEPTH + cos_a * ring * sin_p + tube * sin_a);

        let light = cos_p * cos_t * sin_b - cos_a * cos_t * sin_p - sin_a * sin_t
            + cos_b * (cos_a * sin_t - cos_t * sin_a * sin_p);

        lit(light).map(|level| canvas.project(x, y, inverse_depth, level))
    }
}

impl Default for Donut {
    fn default() -> Self {
        Self::new()
    }
}

impl Canvas {
    fn blank(cols: u16, rows: u16) -> Self {
        let (cols, rows) = (usize::from(cols), usize::from(rows));

        Self {
            cols,
            rows,
            cells: vec![EMPTY; cols * rows],
            depth: vec![0.0; cols * rows],
        }
    }

    fn project(&self, x: f32, y: f32, inverse_depth: f32, level: u8) -> Dot {
        let scale = self.cols as f32 * DEPTH * 3.0 / (8.0 * (TUBE + RING));

        Dot {
            col: self.cols as f32 / 2.0 + scale * inverse_depth * x,
            row: self.rows as f32 / 2.0 - scale * inverse_depth * y / CELL_ASPECT,
            depth: inverse_depth,
            level,
        }
    }

    fn plot(&mut self, dot: Option<Dot>) {
        let Some(dot) = dot else {
            return;
        };

        let Some(index) = self.index(dot.col, dot.row) else {
            return;
        };

        self.paint(index, &dot);
    }

    fn index(&self, col: f32, row: f32) -> Option<usize> {
        let col = usize::try_from(col as i32).ok()?;
        let row = usize::try_from(row as i32).ok()?;

        self.offset(col, row)
    }

    fn offset(&self, col: usize, row: usize) -> Option<usize> {
        (col < self.cols && row < self.rows).then_some(row * self.cols + col)
    }

    fn paint(&mut self, index: usize, dot: &Dot) {
        if dot.depth <= self.depth[index] {
            return;
        }

        self.depth[index] = dot.depth;
        self.cells[index] = dot.level;
    }

    /// Una fila por línea, con los caracteres iguales agrupados: un `Span` por
    /// carácter costaría cientos de asignaciones por cuadro.
    pub fn runs(&self) -> Vec<Vec<Run>> {
        self.cells.chunks(self.cols.max(1)).map(group).collect()
    }
}

/// Intensidad del nivel dentro de la rampa, o `None` para una celda vacía.
pub fn tone(level: u8) -> Option<f32> {
    let last = (RAMP.len() - 1) as f32;

    (usize::from(level) < RAMP.len()).then(|| f32::from(level) / last)
}

fn group(line: &[u8]) -> Vec<Run> {
    let mut runs: Vec<Run> = Vec::new();

    for &level in line {
        push(&mut runs, level);
    }

    runs
}

fn push(runs: &mut Vec<Run>, level: u8) {
    if extend(runs.last_mut(), level) {
        return;
    }

    runs.push(Run {
        level,
        text: String::from(glyph(level)),
    });
}

fn extend(last: Option<&mut Run>, level: u8) -> bool {
    let Some(run) = last.filter(|run| run.level == level) else {
        return false;
    };

    run.text.push(glyph(level));

    true
}

fn glyph(level: u8) -> char {
    match RAMP.get(usize::from(level)) {
        Some(&byte) => char::from(byte),
        None => ' ',
    }
}

fn lit(light: f32) -> Option<u8> {
    let level = (light * 8.0) as i32;

    (light > 0.0).then(|| level.clamp(0, RAMP.len() as i32 - 1) as u8)
}

fn angle(step: u16, steps: u16) -> f32 {
    TAU * f32::from(step) / f32::from(steps)
}

#[cfg(test)]
mod tests {
    use super::*;

    const COLS: u16 = 44;
    const ROWS: u16 = 24;

    fn canvas() -> Canvas {
        Donut::new().render(COLS, ROWS)
    }

    #[test]
    fn the_torus_keeps_its_hole() {
        let canvas = canvas();
        let center = usize::from(ROWS / 2) * usize::from(COLS) + usize::from(COLS / 2);

        assert_eq!(canvas.cells[center], EMPTY);
    }

    #[test]
    fn the_torus_lights_a_range_of_levels() {
        let canvas = canvas();
        let mut levels: Vec<u8> = canvas.cells.iter().copied().filter(|l| *l != EMPTY).collect();
        levels.sort_unstable();
        levels.dedup();

        assert!(levels.len() > 4, "niveles distintos: {levels:?}");
        assert!(levels.iter().all(|level| tone(*level).is_some()));
    }

    #[test]
    fn spinning_changes_the_frame() {
        let mut donut = Donut::new();
        let before = donut.render(COLS, ROWS).cells;

        for _ in 0..10 {
            donut.spin();
        }

        assert_ne!(before, donut.render(COLS, ROWS).cells);
    }
}
