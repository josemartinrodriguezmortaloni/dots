use std::env;
use std::path::PathBuf;
use std::process::{Command, Stdio};

/// Único punto que lanza procesos externos. Centralizarlo mantiene la política
/// de silencio (nada escribe sobre la TUI) en un solo lugar.
pub fn has_command(name: &str) -> bool {
    candidates(name).any(|path| path.is_file())
}

pub fn quiet(program: &str, args: &[&str]) -> bool {
    Command::new(program)
        .args(args)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .is_ok_and(|status| status.success())
}

pub fn capture(program: &str, args: &[&str]) -> Option<String> {
    let output = Command::new(program)
        .args(args)
        .stdin(Stdio::null())
        .stderr(Stdio::null())
        .output()
        .ok()?;

    succeeded(output)
}

fn succeeded(output: std::process::Output) -> Option<String> {
    output
        .status
        .success()
        .then(|| String::from_utf8_lossy(&output.stdout).into_owned())
}

fn candidates(name: &str) -> impl Iterator<Item = PathBuf> {
    let name = name.to_owned();

    env::split_paths(&env::var_os("PATH").unwrap_or_default())
        .map(move |dir| dir.join(&name))
        .collect::<Vec<_>>()
        .into_iter()
}
