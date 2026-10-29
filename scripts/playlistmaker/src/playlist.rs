use crate::pista::{self, Pista};
use serde::Deserialize;
use std::collections::HashSet;
use std::fs::{self, OpenOptions};
use std::io::{ErrorKind, Write};
use std::path::{Path, PathBuf};

/// Vista mínima de una playlist: solo nos interesa qué rutas ya están adentro.
///
/// serde ignora los campos que no declaramos, así que un archivo escrito por
/// cliamp con `codec` o `year` se lee sin problema.
#[derive(Deserialize)]
struct Lista {
    #[serde(default)]
    track: Vec<Entrada>,
}

#[derive(Deserialize)]
struct Entrada {
    path: String,
}

/// Lee el archivo, tratando "no existe" como contenido vacío.
fn leer_o_vacio(archivo: &Path) -> Result<String, String> {
    match fs::read_to_string(archivo) {
        Ok(contenido) => Ok(contenido),
        Err(e) if e.kind() == ErrorKind::NotFound => Ok(String::new()),
        Err(e) => Err(format!("no se pudo leer '{}': {e}", archivo.display())),
    }
}

/// Lee las rutas ya presentes en un archivo de playlist.
///
/// Un archivo que todavía no existe se trata como playlist vacía. Un archivo
/// ilegible o con TOML inválido es un error: anexar a ciegas duplicaría pistas.
pub fn paths_existentes(archivo: &Path) -> Result<HashSet<String>, String> {
    let contenido = leer_o_vacio(archivo)?;
    let lista: Lista = toml::from_str(&contenido)
        .map_err(|e| format!("'{}' no es un TOML válido: {e}", archivo.display()))?;

    Ok(lista.track.into_iter().map(|e| e.path).collect())
}

/// Devuelve las rutas escaneadas que todavía no están en la playlist.
pub fn faltantes(existentes: &HashSet<String>, escaneadas: Vec<PathBuf>) -> Vec<PathBuf> {
    escaneadas
        .into_iter()
        .filter(|ruta| !existentes.contains(ruta.to_string_lossy().as_ref()))
        .collect()
}

/// Agrega los bloques al final del archivo sin tocar lo que ya estaba escrito.
///
/// Abrimos en modo append en vez de reescribir para que sobrevivan el orden, los
/// comentarios y cualquier campo que cliamp escriba y nosotros no conozcamos.
pub fn anexar(archivo: &Path, pistas: &[Pista]) -> Result<(), String> {
    if pistas.is_empty() {
        return Ok(());
    }

    let previo = leer_o_vacio(archivo)?;
    let mut texto = String::new();
    if !previo.is_empty() {
        if !previo.ends_with('\n') {
            texto.push('\n');
        }
        texto.push('\n');
    }
    texto.push_str(&pista::a_toml(pistas));

    OpenOptions::new()
        .create(true)
        .append(true)
        .open(archivo)
        .and_then(|mut f| f.write_all(texto.as_bytes()))
        .map_err(|e| format!("no se pudo escribir '{}': {e}", archivo.display()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn pelada(path: &str) -> Pista {
        Pista {
            path: path.to_string(),
            title: None,
            artist: None,
            album: None,
            year: None,
            track_number: None,
            duration_secs: None,
        }
    }

    #[test]
    fn lee_las_rutas_de_una_playlist_existente() {
        let dir = tempfile::tempdir().unwrap();
        let archivo = dir.path().join("lista.toml");
        fs::write(
            &archivo,
            "[[track]]\npath = \"/musica/a.flac\"\ntitle = \"A\"\n\n\
             [[track]]\npath = \"/musica/b.flac\"\n",
        )
        .unwrap();

        let leidas = paths_existentes(&archivo).unwrap();

        assert_eq!(
            leidas,
            HashSet::from(["/musica/a.flac".to_string(), "/musica/b.flac".to_string()])
        );
    }

    #[test]
    fn una_playlist_que_no_existe_se_trata_como_vacia() {
        let dir = tempfile::tempdir().unwrap();

        let leidas = paths_existentes(&dir.path().join("todavia-no.toml")).unwrap();

        assert!(leidas.is_empty());
    }

    #[test]
    fn una_playlist_con_toml_invalido_es_un_error() {
        let dir = tempfile::tempdir().unwrap();
        let archivo = dir.path().join("rota.toml");
        fs::write(&archivo, "[[track]\npath = sin comillas").unwrap();

        assert!(paths_existentes(&archivo).is_err());
    }

    #[test]
    fn solo_devuelve_las_rutas_que_no_estaban() {
        let existentes = HashSet::from(["/musica/a.flac".to_string()]);
        let escaneadas = vec![
            PathBuf::from("/musica/a.flac"),
            PathBuf::from("/musica/b.flac"),
        ];

        assert_eq!(
            faltantes(&existentes, escaneadas),
            vec![PathBuf::from("/musica/b.flac")]
        );
    }

    #[test]
    fn anexar_a_una_playlist_inexistente_la_crea() {
        let dir = tempfile::tempdir().unwrap();
        let archivo = dir.path().join("nueva.toml");

        anexar(&archivo, &[pelada("/musica/a.flac")]).unwrap();

        assert_eq!(
            fs::read_to_string(&archivo).unwrap(),
            "[[track]]\npath = \"/musica/a.flac\"\n"
        );
    }

    #[test]
    fn anexar_conserva_intacto_lo_que_ya_estaba() {
        let dir = tempfile::tempdir().unwrap();
        let archivo = dir.path().join("lista.toml");
        let previo = "# mi comentario\n[[track]]\npath = \"/musica/a.flac\"\ncodec = \"flac\"\n";
        fs::write(&archivo, previo).unwrap();

        anexar(&archivo, &[pelada("/musica/b.flac")]).unwrap();

        assert_eq!(
            fs::read_to_string(&archivo).unwrap(),
            format!("{previo}\n[[track]]\npath = \"/musica/b.flac\"\n")
        );
    }

    #[test]
    fn anexar_cierra_el_renglon_si_el_archivo_no_terminaba_en_salto() {
        let dir = tempfile::tempdir().unwrap();
        let archivo = dir.path().join("lista.toml");
        fs::write(&archivo, "[[track]]\npath = \"/musica/a.flac\"").unwrap();

        anexar(&archivo, &[pelada("/musica/b.flac")]).unwrap();

        assert_eq!(
            fs::read_to_string(&archivo).unwrap(),
            "[[track]]\npath = \"/musica/a.flac\"\n\n[[track]]\npath = \"/musica/b.flac\"\n"
        );
    }

    #[test]
    fn anexar_sin_pistas_no_toca_el_archivo() {
        let dir = tempfile::tempdir().unwrap();
        let archivo = dir.path().join("lista.toml");
        let previo = "[[track]]\npath = \"/musica/a.flac\"\n";
        fs::write(&archivo, previo).unwrap();

        anexar(&archivo, &[]).unwrap();

        assert_eq!(fs::read_to_string(&archivo).unwrap(), previo);
    }

    #[test]
    fn anexar_sin_pistas_no_crea_un_archivo_vacio() {
        let dir = tempfile::tempdir().unwrap();
        let archivo = dir.path().join("no-deberia-existir.toml");

        anexar(&archivo, &[]).unwrap();

        assert!(!archivo.exists());
    }
}
