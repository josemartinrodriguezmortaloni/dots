use std::env;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use jiff::Zoned;

const STAMP: &str = "%Y%m%d-%H%M%S";

/// Rutas del dominio. `install.sh` exporta `DOTS_ROOT` porque el bootstrap es
/// quien sabe dónde está clonado el repositorio: el binario vive bajo
/// `installer/target/` y deducir la raíz desde su propia ruta se rompe en
/// cuanto cargo cambia el layout de salida.
pub struct Dots {
    root: PathBuf,
    home: PathBuf,
    backup: PathBuf,
}

impl Dots {
    pub fn from_env() -> Result<Self> {
        let root = required("DOTS_ROOT")?;
        let home = required("HOME")?;
        let backup = home.join(".dotfiles-backup").join(stamp());

        Ok(Self { root, home, backup })
    }

    pub fn repo(&self, rel: &str) -> PathBuf {
        self.root.join(rel)
    }

    pub fn home(&self, rel: &str) -> PathBuf {
        self.home.join(rel)
    }

    pub fn root(&self) -> &Path {
        &self.root
    }

    pub fn home_root(&self) -> &Path {
        &self.home
    }

    pub fn backup(&self) -> &Path {
        &self.backup
    }
}

fn required(key: &str) -> Result<PathBuf> {
    env::var_os(key)
        .map(PathBuf::from)
        .with_context(|| format!("falta la variable de entorno {key}"))
}

fn stamp() -> String {
    Zoned::now().strftime(STAMP).to_string()
}
