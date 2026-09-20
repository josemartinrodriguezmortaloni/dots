use std::collections::HashMap;
use std::fs;
use std::path::Path;

use ratatui::style::Color;

use crate::dots::Dots;
use crate::sh;

const RESOLVER: &str = "omarchy-theme-color";
const REPO_THEME: &str = "themes/token-meridian/colors.toml";

pub struct Palette {
    pub background: Color,
    pub foreground: Color,
    pub accent: Color,
    pub muted: Color,
    pub red: Color,
    pub green: Color,
    pub yellow: Color,
    pub selection: Color,
}

pub fn load(dots: &Dots) -> Palette {
    palette(&resolve(dots))
}

/// Precedencia: tema activo de Omarchy, tema del propio repositorio por el
/// mismo resolutor, y parser mínimo cuando Omarchy no está instalado.
/// `omarchy-theme-color` implementa una cascada de alias (ANSI ↔ semánticos,
/// derivación de tonos) que ningún otro consumidor reimplementa.
fn resolve(dots: &Dots) -> HashMap<String, String> {
    let repo_theme = dots.repo(REPO_THEME);

    active()
        .or_else(|| from_file(&repo_theme))
        .unwrap_or_else(|| parse_toml(&repo_theme))
}

fn active() -> Option<HashMap<String, String>> {
    pairs(&sh::capture(RESOLVER, &["--all"])?)
}

fn from_file(path: &Path) -> Option<HashMap<String, String>> {
    let path = path.to_string_lossy().into_owned();

    pairs(&sh::capture(RESOLVER, &["--file", &path, "--all"])?)
}

fn pairs(text: &str) -> Option<HashMap<String, String>> {
    let map: HashMap<String, String> = text.lines().filter_map(split_tab).collect();

    (!map.is_empty()).then_some(map)
}

fn split_tab(line: &str) -> Option<(String, String)> {
    let (key, value) = line.split_once('\t')?;

    Some((key.to_owned(), value.trim().to_owned()))
}

/// Sólo sirve para el `colors.toml` del repositorio: claves planas con valor
/// entre comillas. No pretende ser un parser TOML.
fn parse_toml(path: &Path) -> HashMap<String, String> {
    fs::read_to_string(path)
        .unwrap_or_default()
        .lines()
        .filter_map(split_assignment)
        .collect()
}

fn split_assignment(line: &str) -> Option<(String, String)> {
    let (key, value) = line.split_once('=')?;

    Some((key.trim().to_owned(), value.trim().trim_matches('"').to_owned()))
}

fn palette(map: &HashMap<String, String>) -> Palette {
    Palette {
        background: pick(map, "background"),
        foreground: pick(map, "foreground"),
        accent: pick(map, "accent"),
        muted: pick(map, "muted"),
        red: pick(map, "red"),
        green: pick(map, "green"),
        yellow: pick(map, "yellow"),
        selection: pick(map, "selection_background"),
    }
}

/// Sin valor, el color por defecto del terminal. Ninguna paleta vive duplicada
/// en el código.
fn pick(map: &HashMap<String, String>, key: &str) -> Color {
    map.get(key).and_then(|hex| rgb(hex)).unwrap_or(Color::Reset)
}

fn rgb(hex: &str) -> Option<Color> {
    let digits = hex.strip_prefix('#').filter(|d| d.len() == 6)?;
    let value = u32::from_str_radix(digits, 16).ok()?;

    Some(Color::Rgb(
        (value >> 16) as u8,
        (value >> 8) as u8,
        value as u8,
    ))
}

impl Palette {
    /// Mezcla entre el fondo y el acento. La rampa del donut ya codifica
    /// luminancia, así que el gradiente sale del dato que el render calcula.
    pub fn glow(&self, amount: f32) -> Color {
        mix(self.background, self.accent, amount)
    }
}

fn mix(from: Color, to: Color, amount: f32) -> Color {
    let (Color::Rgb(r, g, b), Color::Rgb(x, y, z)) = (from, to) else {
        return to;
    };

    Color::Rgb(
        blend(r, x, amount),
        blend(g, y, amount),
        blend(b, z, amount),
    )
}

fn blend(from: u8, to: u8, amount: f32) -> u8 {
    let start = f32::from(from);

    (start + (f32::from(to) - start) * amount).round() as u8
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reads_hex_colors_and_rejects_the_rest() {
        assert_eq!(rgb("#e89a49"), Some(Color::Rgb(0xe8, 0x9a, 0x49)));
        assert_eq!(rgb("e89a49"), None);
        assert_eq!(rgb("#e89a4"), None);
    }

    #[test]
    fn reads_the_resolver_output() {
        let map = pairs("accent\t#e89a49\nbackground\t#272724\n").expect("pares");

        assert_eq!(map.get("accent"), Some(&"#e89a49".to_owned()));
        assert_eq!(pairs(""), None);
    }

    #[test]
    fn reads_the_repo_theme_file() {
        let dir = tempfile::TempDir::new().expect("tempdir");
        let path = dir.path().join("colors.toml");
        std::fs::write(&path, "# comentario\nmode = \"dark\"\naccent = \"#e89a49\"\n")
            .expect("escribir");

        let map = parse_toml(&path);

        assert_eq!(map.get("accent"), Some(&"#e89a49".to_owned()));
        assert_eq!(map.get("mode"), Some(&"dark".to_owned()));
    }

    #[test]
    fn missing_keys_fall_back_to_the_terminal_default() {
        assert_eq!(pick(&HashMap::new(), "accent"), Color::Reset);
    }

    #[test]
    fn the_gradient_walks_from_background_to_accent() {
        let from = Color::Rgb(0, 0, 0);
        let to = Color::Rgb(100, 200, 50);

        assert_eq!(mix(from, to, 0.0), from);
        assert_eq!(mix(from, to, 1.0), to);
        assert_eq!(mix(from, to, 0.5), Color::Rgb(50, 100, 25));
    }
}
