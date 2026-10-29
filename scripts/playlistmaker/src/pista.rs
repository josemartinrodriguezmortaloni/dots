use serde::Serialize;
use std::path::Path;

/// Una pista tal como la serializa cliamp en sus archivos de playlist.
///
/// El orden de los campos define el orden de las líneas en el TOML, y los
/// campos sin dato se omiten en vez de escribirse vacíos.
#[derive(Debug, Serialize, PartialEq, Eq)]
pub struct Pista {
    pub path: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub title: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub artist: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub album: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub year: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub track_number: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub duration_secs: Option<u64>,
}

/// Lo que sale de los tags del archivo, todavía sin interpretar.
///
/// `year` llega como texto porque los tags guardan cualquier cosa ahí: "1999",
/// "1999-05-10", "1999/05" o directamente basura.
#[derive(Debug, Default)]
pub struct Crudos {
    pub title: Option<String>,
    pub artist: Option<String>,
    pub album: Option<String>,
    pub year: Option<String>,
    pub track_number: Option<u32>,
    pub duration_secs: Option<u64>,
}

/// Rango de números de pista que consideramos creíble.
///
/// Sirve para no confundir un año al principio del nombre ("1979 - …") con el
/// número de pista.
const PISTAS_PLAUSIBLES: std::ops::RangeInclusive<u32> = 1..=999;

/// Rango de años que consideramos creíble para una grabación.
const ANIOS_PLAUSIBLES: std::ops::RangeInclusive<u32> = 1900..=2200;

/// Descarta los tags presentes pero vacíos, que equivalen a no tener el dato.
fn no_vacio(valor: Option<String>) -> Option<String> {
    valor
        .map(|v| v.trim().to_string())
        .filter(|v| !v.is_empty())
}

/// Separa el número de pista del principio del nombre, si lo hay.
///
/// Devuelve el número y el resto del nombre ya sin el prefijo. Exige un
/// separador (`.`, `-`, `_` o espacio) entre el número y el resto para no
/// mutilar nombres que simplemente arrancan con dígitos.
fn separar_numero(stem: &str) -> (Option<u32>, &str) {
    let fin = stem
        .find(|c: char| !c.is_ascii_digit())
        .unwrap_or(stem.len());

    let numero = stem[..fin]
        .parse::<u32>()
        .ok()
        .filter(|n| PISTAS_PLAUSIBLES.contains(n));
    let Some(numero) = numero else {
        return (None, stem);
    };

    let cola = &stem[fin..];
    let resto = cola.trim_start_matches(['.', '-', '_', ' ']);
    if resto.is_empty() || resto.len() == cola.len() {
        return (None, stem);
    }

    (Some(numero), resto)
}

/// Separa "Artista - Título" por el primer " - " que aparezca.
///
/// Cortar por el primero y no por el último deja el título entero aunque
/// contenga guiones, que es lo común en versiones en vivo y remasters.
fn separar_artista(nombre: &str) -> (Option<String>, String) {
    match nombre.split_once(" - ") {
        Some((artista, titulo)) if !artista.trim().is_empty() && !titulo.trim().is_empty() => {
            (Some(artista.trim().to_string()), titulo.trim().to_string())
        }
        _ => (None, nombre.trim().to_string()),
    }
}

/// Extrae el año de un tag de fecha, que puede venir como "1999" o "1999-05-10".
fn parsear_anio(crudo: &str) -> Option<u32> {
    crudo
        .trim()
        .get(..4)?
        .parse::<u32>()
        .ok()
        .filter(|a| ANIOS_PLAUSIBLES.contains(a))
}

/// Arma la `Pista` que se va a escribir a partir de la ruta y sus tags.
///
/// Los tags mandan siempre que estén. Cuando faltan —el caso normal en una
/// biblioteca bajada de internet— se deduce lo que se pueda del nombre del
/// archivo, que suele seguir el patrón "NN. Artista - Título".
pub fn desde_partes(ruta: &Path, crudos: Crudos) -> Pista {
    let stem = ruta.file_stem().unwrap_or_default().to_string_lossy();
    let (numero_nombre, resto) = separar_numero(&stem);
    let (artista_nombre, titulo_nombre) = separar_artista(resto);

    Pista {
        path: ruta.to_string_lossy().into_owned(),
        title: no_vacio(crudos.title).or(no_vacio(Some(titulo_nombre))),
        artist: no_vacio(crudos.artist).or(artista_nombre),
        album: no_vacio(crudos.album),
        year: crudos.year.as_deref().and_then(parsear_anio),
        track_number: crudos.track_number.or(numero_nombre),
        duration_secs: crudos.duration_secs,
    }
}

/// Serializa las pistas como una secuencia de bloques `[[track]]`.
///
/// Armamos el encabezado a mano en vez de serializar un array de tablas porque
/// así el bloque queda idéntico al que escribe cliamp y podemos anexarlo tal
/// cual al final de un archivo existente.
pub fn a_toml(pistas: &[Pista]) -> String {
    pistas
        .iter()
        .map(|pista| {
            let campos = toml::to_string(pista).expect("una Pista siempre serializa a TOML");
            format!("[[track]]\n{campos}")
        })
        .collect::<Vec<_>>()
        .join("\n")
}

#[cfg(test)]
mod tests {
    use super::*;

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
    fn traslada_los_tags_completos_a_la_pista() {
        let pista = desde_partes(
            Path::new("/musica/Cerati/01. Tabú.flac"),
            Crudos {
                title: Some("Tabú".to_string()),
                artist: Some("Gustavo Cerati".to_string()),
                album: Some("Bocanada".to_string()),
                year: Some("1999".to_string()),
                track_number: Some(1),
                duration_secs: Some(288),
            },
        );

        assert_eq!(
            pista,
            Pista {
                path: "/musica/Cerati/01. Tabú.flac".to_string(),
                title: Some("Tabú".to_string()),
                artist: Some("Gustavo Cerati".to_string()),
                album: Some("Bocanada".to_string()),
                year: Some(1999),
                track_number: Some(1),
                duration_secs: Some(288),
            }
        );
    }

    #[test]
    fn la_ruta_del_archivo_siempre_llega_a_la_pista() {
        let pista = desde_partes(Path::new("/musica/sin-tags.flac"), Crudos::default());

        assert_eq!(pista.path, "/musica/sin-tags.flac");
    }

    /// El caso habitual de esta biblioteca: casi ningún archivo trae tags, pero
    /// el nombre sigue el patrón "NN. Artista - Título".
    #[test]
    fn sin_tags_deduce_numero_artista_y_titulo_del_nombre() {
        let pista = desde_partes(
            Path::new("/musica/aespa/01. aespa - Supernova.flac"),
            Crudos::default(),
        );

        assert_eq!(pista.track_number, Some(1));
        assert_eq!(pista.artist.as_deref(), Some("aespa"));
        assert_eq!(pista.title.as_deref(), Some("Supernova"));
    }

    #[test]
    fn deduce_igual_con_numero_de_un_solo_digito() {
        let pista = desde_partes(
            Path::new("/musica/BNYX/1. BNYX® - ROOM OF SMILES.flac"),
            Crudos::default(),
        );

        assert_eq!(pista.track_number, Some(1));
        assert_eq!(pista.artist.as_deref(), Some("BNYX®"));
        assert_eq!(pista.title.as_deref(), Some("ROOM OF SMILES"));
    }

    /// Se corta en el primer " - ": lo que sigue es el título completo, guiones
    /// incluidos.
    #[test]
    fn un_titulo_con_guion_adentro_no_se_parte_de_mas() {
        let pista = desde_partes(
            Path::new("/musica/03. Soda Stereo - En la ciudad de la furia - En vivo.flac"),
            Crudos::default(),
        );

        assert_eq!(pista.artist.as_deref(), Some("Soda Stereo"));
        assert_eq!(
            pista.title.as_deref(),
            Some("En la ciudad de la furia - En vivo")
        );
    }

    #[test]
    fn sin_separador_de_artista_todo_el_nombre_queda_como_titulo() {
        let pista = desde_partes(Path::new("/musica/07. Prologue.flac"), Crudos::default());

        assert_eq!(pista.track_number, Some(7));
        assert_eq!(pista.artist, None);
        assert_eq!(pista.title.as_deref(), Some("Prologue"));
    }

    #[test]
    fn sin_prefijo_numerico_no_se_inventa_numero_de_pista() {
        let pista = desde_partes(
            Path::new("/musica/aespa/aespa - Dirty Work.flac"),
            Crudos::default(),
        );

        assert_eq!(pista.track_number, None);
        assert_eq!(pista.artist.as_deref(), Some("aespa"));
        assert_eq!(pista.title.as_deref(), Some("Dirty Work"));
    }

    /// Un año al principio del nombre no es un número de pista.
    #[test]
    fn un_numero_inverosimil_no_se_toma_como_numero_de_pista() {
        let pista = desde_partes(
            Path::new("/musica/1979 - The Smashing Pumpkins.flac"),
            Crudos::default(),
        );

        assert_eq!(pista.track_number, None);
    }

    #[test]
    fn los_tags_le_ganan_a_lo_deducido_del_nombre() {
        let pista = desde_partes(
            Path::new("/musica/01. aespa - Supernova.flac"),
            Crudos {
                title: Some("슈퍼노바".to_string()),
                artist: Some("에스파".to_string()),
                track_number: Some(4),
                ..Crudos::default()
            },
        );

        assert_eq!(pista.title.as_deref(), Some("슈퍼노바"));
        assert_eq!(pista.artist.as_deref(), Some("에스파"));
        assert_eq!(pista.track_number, Some(4));
    }

    #[test]
    fn de_una_fecha_completa_se_queda_con_el_anio() {
        let pista = desde_partes(
            Path::new("/musica/tema.flac"),
            Crudos {
                year: Some("2025-06-26".to_string()),
                ..Crudos::default()
            },
        );

        assert_eq!(pista.year, Some(2025));
    }

    #[test]
    fn descarta_los_anios_que_no_tienen_sentido() {
        for basura in ["", "0", "99999", "sin fecha", "0000"] {
            let pista = desde_partes(
                Path::new("/musica/tema.flac"),
                Crudos {
                    year: Some(basura.to_string()),
                    ..Crudos::default()
                },
            );

            assert_eq!(pista.year, None, "'{basura}' no debería dar un año");
        }
    }

    #[test]
    fn un_tag_vacio_se_trata_como_ausente() {
        let pista = desde_partes(
            Path::new("/musica/01. aespa - Supernova.flac"),
            Crudos {
                title: Some("   ".to_string()),
                artist: Some(String::new()),
                album: Some(String::new()),
                ..Crudos::default()
            },
        );

        assert_eq!(pista.title.as_deref(), Some("Supernova"));
        assert_eq!(pista.artist.as_deref(), Some("aespa"));
        assert_eq!(pista.album, None);
    }

    #[test]
    fn serializa_una_pista_completa_como_bloque_track() {
        let pista = Pista {
            path: "/home/m4s1t4/Music/Cerati/01. Tabú.flac".to_string(),
            title: Some("Tabú".to_string()),
            artist: Some("Gustavo Cerati".to_string()),
            album: Some("Bocanada".to_string()),
            year: Some(1999),
            track_number: Some(1),
            duration_secs: Some(288),
        };

        assert_eq!(
            a_toml(&[pista]),
            "[[track]]\n\
             path = \"/home/m4s1t4/Music/Cerati/01. Tabú.flac\"\n\
             title = \"Tabú\"\n\
             artist = \"Gustavo Cerati\"\n\
             album = \"Bocanada\"\n\
             year = 1999\n\
             track_number = 1\n\
             duration_secs = 288\n"
        );
    }

    #[test]
    fn omite_las_lineas_de_los_campos_sin_dato() {
        assert_eq!(
            a_toml(&[pelada("/musica/tema.flac")]),
            "[[track]]\npath = \"/musica/tema.flac\"\n"
        );
    }

    #[test]
    fn separa_los_bloques_con_una_linea_en_blanco() {
        assert_eq!(
            a_toml(&[pelada("/musica/a.flac"), pelada("/musica/b.flac")]),
            "[[track]]\npath = \"/musica/a.flac\"\n\
             \n\
             [[track]]\npath = \"/musica/b.flac\"\n"
        );
    }

    /// No nos importa qué estilo de comillas elija el serializador, sino que la
    /// ruta se pueda volver a leer intacta. Los nombres de archivo reales traen
    /// acentos, comillas y backslashes.
    #[test]
    fn las_rutas_con_caracteres_especiales_sobreviven_el_round_trip() {
        let rutas = [
            "/musica/Say \"Yes\".flac",
            "/musica/AC\\DC - Back in Black.flac",
            "/musica/Gustavo Cerati - Ahí Vamos/01. Tabú.flac",
            "/musica/aespa - Long Chat (#♥).flac",
        ];

        let texto = a_toml(&rutas.map(pelada));
        let leido: toml::Table = texto.parse().expect("el TOML generado debe ser parseable");

        let vueltas: Vec<&str> = leido["track"]
            .as_array()
            .unwrap()
            .iter()
            .map(|t| t["path"].as_str().unwrap())
            .collect();

        assert_eq!(vueltas, rutas);
    }

    #[test]
    fn no_escribe_nada_si_no_hay_pistas() {
        assert_eq!(a_toml(&[]), "");
    }
}
