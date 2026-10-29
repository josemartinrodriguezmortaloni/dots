mod escaneo;
mod lectura;
mod pista;
mod playlist;

use clap::Parser;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

/// Crea o actualiza las playlists de cliamp a partir de tu biblioteca local.
///
/// Recorre las carpetas de primer nivel del directorio de música y escribe un
/// archivo por carpeta. Las pistas que ya están en la playlist no se tocan:
/// solo se agregan al final las que aparecieron desde la última corrida.
#[derive(Parser, Debug)]
#[command(version, about)]
struct Cli {
    /// Directorio que contiene las carpetas de música
    #[arg(long, value_name = "DIR", default_value = "~/Music", value_hint = clap::ValueHint::DirPath)]
    musica: String,

    /// Directorio donde cliamp guarda sus playlists
    #[arg(long, value_name = "DIR", default_value = "~/.config/cliamp/playlists", value_hint = clap::ValueHint::DirPath)]
    playlists: String,
}

struct Entradas {
    musica: PathBuf,
    playlists: PathBuf,
}

/// Expande un `~` inicial y convierte la ruta en absoluta.
///
/// Las rutas de la playlist deben ser absolutas para que cliamp las encuentre
/// desde cualquier directorio de trabajo.
fn expandir(ruta: &str) -> Result<PathBuf, String> {
    let expandida = match ruta.strip_prefix("~/") {
        Some(resto) => {
            let hogar = std::env::home_dir().ok_or("no se pudo determinar el directorio home")?;
            hogar.join(resto)
        }
        None => PathBuf::from(ruta),
    };

    std::path::absolute(&expandida)
        .map_err(|e| format!("ruta inválida '{}': {e}", expandida.display()))
}

fn validar(cli: Cli) -> Result<Entradas, String> {
    let musica = expandir(&cli.musica)?;
    if !musica.is_dir() {
        return Err(format!(
            "'{}' no es un directorio existente",
            musica.display()
        ));
    }

    let playlists = expandir(&cli.playlists)?;
    std::fs::create_dir_all(&playlists)
        .map_err(|e| format!("no se pudo crear '{}': {e}", playlists.display()))?;

    Ok(Entradas { musica, playlists })
}

/// Las carpetas de primer nivel de la biblioteca, en orden alfabético.
fn colecciones(musica: &Path) -> Result<Vec<PathBuf>, String> {
    let entradas = std::fs::read_dir(musica)
        .map_err(|e| format!("no se pudo leer '{}': {e}", musica.display()))?;

    let mut carpetas: Vec<PathBuf> = entradas
        .filter_map(Result::ok)
        .map(|e| e.path())
        .filter(|r| r.is_dir())
        .collect();
    carpetas.sort();

    Ok(carpetas)
}

/// Sincroniza una carpeta con su playlist. Devuelve cuántas pistas se agregaron.
fn sincronizar(carpeta: &Path, dir_playlists: &Path) -> Result<usize, String> {
    let nombre = carpeta
        .file_name()
        .ok_or_else(|| format!("'{}' no tiene nombre de carpeta", carpeta.display()))?;
    let archivo = dir_playlists.join(nombre).with_extension("toml");

    let existentes = playlist::paths_existentes(&archivo)?;
    let nuevas = playlist::faltantes(&existentes, escaneo::rutas_de_audio(carpeta));
    let pistas: Vec<pista::Pista> = nuevas.iter().map(|r| lectura::leer(r)).collect();

    playlist::anexar(&archivo, &pistas)?;

    Ok(pistas.len())
}

fn main() -> ExitCode {
    let entradas = match validar(Cli::parse()) {
        Ok(entradas) => entradas,
        Err(mensaje) => {
            eprintln!("Error: {mensaje}");
            return ExitCode::FAILURE;
        }
    };

    let carpetas = match colecciones(&entradas.musica) {
        Ok(carpetas) => carpetas,
        Err(mensaje) => {
            eprintln!("Error: {mensaje}");
            return ExitCode::FAILURE;
        }
    };

    // Alineamos la salida al nombre de carpeta más largo.
    let ancho = carpetas
        .iter()
        .filter_map(|c| c.file_name())
        .map(|n| n.to_string_lossy().chars().count())
        .max()
        .unwrap_or(0);

    let mut hubo_errores = false;
    for carpeta in &carpetas {
        let nombre = carpeta.file_name().unwrap_or_default().to_string_lossy();
        match sincronizar(carpeta, &entradas.playlists) {
            Ok(0) => println!("{nombre:ancho$}  sin cambios"),
            Ok(n) => println!("{nombre:ancho$}  +{n} pistas"),
            Err(mensaje) => {
                eprintln!("{nombre:ancho$}  ✗ {mensaje}");
                hubo_errores = true;
            }
        }
    }

    if hubo_errores {
        ExitCode::FAILURE
    } else {
        ExitCode::SUCCESS
    }
}
