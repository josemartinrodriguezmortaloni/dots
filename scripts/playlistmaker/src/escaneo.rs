use std::path::{Path, PathBuf};
use walkdir::WalkDir;

/// Extensiones que consideramos audio. El resto (carátulas, cue, logs) se ignora.
const EXTENSIONES: [&str; 6] = ["flac", "mp3", "m4a", "ogg", "opus", "wav"];

fn es_audio(ruta: &Path) -> bool {
    ruta.extension()
        .and_then(|e| e.to_str())
        .is_some_and(|e| EXTENSIONES.contains(&e.to_ascii_lowercase().as_str()))
}

/// Recorre `carpeta` recursivamente y devuelve las rutas de audio ordenadas.
///
/// Los subdirectorios ilegibles se saltean en silencio: una carpeta sin permisos
/// no debe abortar el escaneo del resto de la biblioteca.
pub fn rutas_de_audio(carpeta: &Path) -> Vec<PathBuf> {
    WalkDir::new(carpeta)
        .sort_by_file_name()
        .into_iter()
        .filter_map(Result::ok)
        .filter(|e| e.file_type().is_file())
        .map(walkdir::DirEntry::into_path)
        .filter(|r| es_audio(r))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    /// Crea un archivo vacío, creando los directorios padres que falten.
    fn tocar(base: &Path, relativa: &str) -> PathBuf {
        let ruta = base.join(relativa);
        fs::create_dir_all(ruta.parent().unwrap()).unwrap();
        fs::write(&ruta, b"").unwrap();
        ruta
    }

    #[test]
    fn encuentra_audio_en_cualquier_nivel_de_anidamiento() {
        let dir = tempfile::tempdir().unwrap();
        let suelta = tocar(dir.path(), "suelta.flac");
        let en_album = tocar(dir.path(), "Album (1999)/01 tema.flac");
        let bien_hondo = tocar(dir.path(), "Artista/Album/Disco 2/02 tema.mp3");

        let mut encontradas = rutas_de_audio(dir.path());
        encontradas.sort();
        let mut esperadas = vec![suelta, en_album, bien_hondo];
        esperadas.sort();

        assert_eq!(encontradas, esperadas);
    }

    #[test]
    fn ignora_archivos_que_no_son_audio() {
        let dir = tempfile::tempdir().unwrap();
        tocar(dir.path(), "cover.jpg");
        tocar(dir.path(), "notas.txt");
        tocar(dir.path(), "Album/folder.png");

        assert_eq!(rutas_de_audio(dir.path()), Vec::<PathBuf>::new());
    }

    #[test]
    fn reconoce_la_extension_sin_importar_mayusculas() {
        let dir = tempfile::tempdir().unwrap();
        let grito = tocar(dir.path(), "TEMA.FLAC");

        assert_eq!(rutas_de_audio(dir.path()), vec![grito]);
    }

    #[test]
    fn devuelve_las_rutas_en_orden_alfabetico() {
        let dir = tempfile::tempdir().unwrap();
        tocar(dir.path(), "03 tercera.flac");
        tocar(dir.path(), "01 primera.flac");
        tocar(dir.path(), "02 segunda.flac");

        let nombres: Vec<String> = rutas_de_audio(dir.path())
            .iter()
            .map(|r| r.file_name().unwrap().to_string_lossy().into_owned())
            .collect();

        assert_eq!(
            nombres,
            ["01 primera.flac", "02 segunda.flac", "03 tercera.flac"]
        );
    }
}
