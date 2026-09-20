use std::path::PathBuf;

/// Una operación del plan. `plan` las calcula leyendo el filesystem sin
/// escribirlo; `link::apply` es el único punto que lo modifica. La separación
/// es lo que permite la pantalla de confirmación: el plan se puede mostrar
/// entero antes de que se mueva un solo archivo.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Op {
    Link { src: PathBuf, dest: PathBuf },
    Remove { dest: PathBuf },
    SkipCursorThemeChanges { flag: PathBuf },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Outcome {
    Linked,
    Replaced,
    AlreadyLinked,
    Removed,
    Flagged,
    Skipped,
}

impl Outcome {
    pub fn links(self) -> bool {
        matches!(self, Outcome::Linked | Outcome::Replaced)
    }

    pub fn backs_up(self) -> bool {
        matches!(self, Outcome::Replaced)
    }
}
