use std::env;

use anyhow::{Context, Result, bail};

/// El equipo destino. Sólo cambia la disposición de monitores: el resto de la
/// configuración es idéntica en ambos. `install.sh` lo pregunta y lo exporta en
/// `DOTS_MACHINE`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Machine {
    Desktop,
    Notebook,
}

impl Machine {
    pub fn from_env() -> Result<Self> {
        let value = env::var("DOTS_MACHINE").context("falta la variable de entorno DOTS_MACHINE")?;

        Self::parse(&value)
    }

    fn parse(value: &str) -> Result<Self> {
        match value {
            "desktop" => Ok(Machine::Desktop),
            "notebook" => Ok(Machine::Notebook),
            other => bail!("DOTS_MACHINE inválido: {other} (desktop | notebook)"),
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
