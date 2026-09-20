use std::fs;
use std::os::unix::fs as unix;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};

use crate::ops::{Op, Outcome};
use crate::sh;

const CURSOR_PROBE_SECONDS: &str = "8";

/// Destino de los archivos que el instalador desplaza. Es la única operación
/// destructiva del programa, así que vive sola y con su propio nombre.
pub struct Backup {
    root: PathBuf,
    home: PathBuf,
}

impl Backup {
    pub fn new(root: &Path, home: &Path) -> Self {
        Self {
            root: root.to_owned(),
            home: home.to_owned(),
        }
    }

    pub fn root(&self) -> &Path {
        &self.root
    }

    fn stash(&self, dest: &Path) -> Result<bool> {
        if dest.symlink_metadata().is_err() {
            return Ok(false);
        }

        self.displace(dest)?;

        Ok(true)
    }

    fn displace(&self, dest: &Path) -> Result<()> {
        let target = self.target_for(dest)?;
        ensure_parent(&target)?;

        move_aside(dest, &target)
    }

    fn target_for(&self, dest: &Path) -> Result<PathBuf> {
        let rel = dest
            .strip_prefix(&self.home)
            .with_context(|| format!("{} queda fuera de HOME", dest.display()))?;

        Ok(self.root.join(rel))
    }
}

pub fn apply(op: &Op, backup: &Backup) -> Result<Outcome> {
    match op {
        Op::Link { src, dest } => link(src, dest, backup),
        Op::Remove { dest } => remove(dest),
        Op::SkipCursorThemeChanges { flag } => flag_cursor(flag),
    }
}

/// Lo que la pantalla de confirmación necesita saber antes de escribir nada.
pub fn would_replace(src: &Path, dest: &Path) -> bool {
    !already_linked(src, dest) && dest.symlink_metadata().is_ok()
}

fn link(src: &Path, dest: &Path, backup: &Backup) -> Result<Outcome> {
    if already_linked(src, dest) {
        return Ok(Outcome::AlreadyLinked);
    }

    let replaced = backup.stash(dest)?;

    place(src, dest).map(|()| placed(replaced))
}

fn place(src: &Path, dest: &Path) -> Result<()> {
    ensure_parent(dest)?;

    unix::symlink(src, dest).with_context(|| format!("no se pudo enlazar {}", dest.display()))
}

fn move_aside(dest: &Path, target: &Path) -> Result<()> {
    fs::rename(dest, target).with_context(|| format!("no se pudo respaldar {}", dest.display()))
}

fn placed(replaced: bool) -> Outcome {
    match replaced {
        true => Outcome::Replaced,
        false => Outcome::Linked,
    }
}

fn remove(dest: &Path) -> Result<Outcome> {
    let Ok(meta) = dest.symlink_metadata() else {
        return Ok(Outcome::Skipped);
    };

    discard(dest, meta.is_dir())
}

/// Un directorio sobrante sólo desaparece si quedó vacío: `remove_dir` falla
/// con contenido adentro y ese fallo es la respuesta correcta, no un error.
fn discard(dest: &Path, is_dir: bool) -> Result<Outcome> {
    if is_dir {
        return Ok(dropped(fs::remove_dir(dest).is_ok()));
    }

    delete(dest)
}

fn delete(dest: &Path) -> Result<Outcome> {
    fs::remove_file(dest)
        .map(|()| Outcome::Removed)
        .with_context(|| format!("no se pudo borrar {}", dest.display()))
}

fn dropped(done: bool) -> Outcome {
    match done {
        true => Outcome::Removed,
        false => Outcome::Skipped,
    }
}

/// El CLI de Cursor se cuelga en `--list-extensions` y con eso congela
/// `omarchy-theme-set` antes de que corra el hook `theme-set`. El flag le dice
/// a Omarchy que lo saltee durante los cambios de tema.
fn flag_cursor(flag: &Path) -> Result<Outcome> {
    if !cursor_stalls() {
        return Ok(Outcome::Skipped);
    }

    raise(flag).map(|()| Outcome::Flagged)
}

fn raise(flag: &Path) -> Result<()> {
    ensure_parent(flag)?;

    fs::File::create(flag)
        .map(drop)
        .with_context(|| format!("no se pudo crear {}", flag.display()))
}

fn cursor_stalls() -> bool {
    sh::has_command("cursor")
        && !sh::quiet("timeout", &[CURSOR_PROBE_SECONDS, "cursor", "--list-extensions"])
}

fn already_linked(src: &Path, dest: &Path) -> bool {
    is_symlink(dest) && same_target(src, dest)
}

pub fn is_symlink(path: &Path) -> bool {
    path.symlink_metadata().is_ok_and(|meta| meta.is_symlink())
}

/// Comparar sólo rutas canónicas falla cuando el origen no existe: los dos
/// `canonicalize` devuelven error, el enlace correcto se declara incorrecto y
/// cada corrida lo respalda y lo vuelve a crear. El destino del enlace se
/// compara primero, que es exactamente lo que el instalador escribió.
fn same_target(src: &Path, dest: &Path) -> bool {
    points_at(src, dest) || resolves_to(src, dest)
}

fn points_at(src: &Path, dest: &Path) -> bool {
    fs::read_link(dest).is_ok_and(|target| target == src)
}

fn resolves_to(src: &Path, dest: &Path) -> bool {
    resolve(dest).zip(resolve(src)).is_some_and(|(a, b)| a == b)
}

fn resolve(path: &Path) -> Option<PathBuf> {
    fs::canonicalize(path).ok()
}

fn ensure_parent(path: &Path) -> Result<()> {
    let Some(parent) = path.parent() else {
        return Ok(());
    };

    fs::create_dir_all(parent).with_context(|| format!("no se pudo crear {}", parent.display()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    fn fixture() -> (TempDir, Backup) {
        let dir = TempDir::new().expect("tempdir");
        let home = dir.path().join("home");
        fs::create_dir_all(&home).expect("home");

        let backup = Backup::new(&dir.path().join("backup"), &home);

        (dir, backup)
    }

    fn source(dir: &TempDir, name: &str, body: &str) -> PathBuf {
        let path = dir.path().join(name);
        fs::write(&path, body).expect("source");

        path
    }

    fn dest(dir: &TempDir) -> PathBuf {
        dir.path().join("home/.config/app/config")
    }

    fn link_op(src: &Path, dest: &Path) -> Op {
        Op::Link {
            src: src.to_owned(),
            dest: dest.to_owned(),
        }
    }

    #[test]
    fn creates_the_link_when_the_destination_is_free() {
        let (dir, backup) = fixture();
        let src = source(&dir, "config", "nuevo");
        let dest = dest(&dir);

        let outcome = apply(&link_op(&src, &dest), &backup).expect("apply");

        assert_eq!(outcome, Outcome::Linked);
        assert_eq!(fs::read_link(&dest).expect("readlink"), src);
        assert!(!backup.root().exists());
    }

    #[test]
    fn leaves_an_existing_correct_link_untouched() {
        let (dir, backup) = fixture();
        let src = source(&dir, "config", "nuevo");
        let dest = dest(&dir);

        apply(&link_op(&src, &dest), &backup).expect("primera");
        let outcome = apply(&link_op(&src, &dest), &backup).expect("segunda");

        assert_eq!(outcome, Outcome::AlreadyLinked);
        assert!(!backup.root().exists());
        assert!(!would_replace(&src, &dest));
    }

    #[test]
    fn backs_up_a_real_file_before_replacing_it() {
        let (dir, backup) = fixture();
        let src = source(&dir, "config", "nuevo");
        let dest = dest(&dir);
        fs::create_dir_all(dest.parent().expect("parent")).expect("mkdir");
        fs::write(&dest, "viejo").expect("previo");

        assert!(would_replace(&src, &dest));
        let outcome = apply(&link_op(&src, &dest), &backup).expect("apply");

        assert_eq!(outcome, Outcome::Replaced);
        assert_eq!(fs::read_link(&dest).expect("readlink"), src);
        let stashed = backup.root().join(".config/app/config");
        assert_eq!(fs::read_to_string(stashed).expect("backup"), "viejo");
    }

    #[test]
    fn backs_up_a_link_that_points_somewhere_else() {
        let (dir, backup) = fixture();
        let src = source(&dir, "config", "nuevo");
        let other = source(&dir, "otro", "ajeno");
        let dest = dest(&dir);
        fs::create_dir_all(dest.parent().expect("parent")).expect("mkdir");
        unix::symlink(&other, &dest).expect("link ajeno");

        let outcome = apply(&link_op(&src, &dest), &backup).expect("apply");

        assert_eq!(outcome, Outcome::Replaced);
        assert_eq!(fs::read_link(&dest).expect("readlink"), src);
        let stashed = backup.root().join(".config/app/config");
        assert_eq!(fs::read_link(stashed).expect("backup"), other);
    }

    #[test]
    fn a_correct_link_stays_correct_when_its_source_is_missing() {
        let (dir, backup) = fixture();
        let src = dir.path().join("todavia-no-existe");
        let dest = dest(&dir);

        let first = apply(&link_op(&src, &dest), &backup).expect("primera");
        let second = apply(&link_op(&src, &dest), &backup).expect("segunda");

        assert_eq!(first, Outcome::Linked);
        assert_eq!(second, Outcome::AlreadyLinked);
        assert!(!backup.root().exists());
    }

    #[test]
    fn removing_a_missing_path_is_not_an_error() {
        let (dir, backup) = fixture();
        let op = Op::Remove {
            dest: dir.path().join("home/no-existe"),
        };

        assert_eq!(apply(&op, &backup).expect("apply"), Outcome::Skipped);
    }
}
