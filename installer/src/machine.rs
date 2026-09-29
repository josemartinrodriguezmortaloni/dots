use std::env;

use anyhow::{Result, bail};

/// El equipo destino. Sólo cambia la disposición de monitores: el resto de la
/// configuración es idéntica en ambos. La TUI lo pregunta; `DOTS_MACHINE` evita
/// la pregunta y es obligatorio en `--all`, que corre sin terminal.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Machine {
    Desktop,
    Notebook,
}

impl Machine {
    /// Orden de las opciones en la pantalla de elección.
    pub const ALL: [Machine; 2] = [Machine::Desktop, Machine::Notebook];

    /// `None` si la variable no está exportada: el equipo queda por elegir.
    pub fn from_env() -> Result<Option<Self>> {
        env::var("DOTS_MACHINE").ok().map(|value| Self::parse(&value)).transpose()
    }

    fn parse(value: &str) -> Result<Self> {
        match value {
            "desktop" => Ok(Machine::Desktop),
            "notebook" => Ok(Machine::Notebook),
            other => bail!("DOTS_MACHINE inválido: {other} (desktop | notebook)"),
        }
    }

    pub fn label(self) -> &'static str {
        match self {
            Machine::Desktop => "pc de escritorio",
            Machine::Notebook => "notebook",
        }
    }

    /// Perfil de `hypr/` que se enlaza como `~/.config/hypr/monitors.lua`.
    pub fn monitors(self) -> &'static str {
        match self {
            Machine::Desktop => "monitors-esc.lua",
            Machine::Notebook => "monitors.lua",
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_accepts_both_machines() {
        assert_eq!(Machine::parse("desktop").expect("desktop"), Machine::Desktop);
        assert_eq!(Machine::parse("notebook").expect("notebook"), Machine::Notebook);
    }

    #[test]
    fn parse_rejects_unknown_machine() {
        assert!(Machine::parse("server").is_err());
    }
}
