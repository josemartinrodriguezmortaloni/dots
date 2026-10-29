use crate::pista::{Crudos, Pista, desde_partes};
use lofty::prelude::*;
use lofty::tag::Tag;
use std::path::Path;

/// Extrae los tags de un archivo de audio y arma su `Pista`.
///
/// Este módulo no decide nada: traduce lo que devuelve lofty a `Crudos` y deja
/// la interpretación en `pista::desde_partes`. Un archivo sin tags legibles
/// igual produce una `Pista`, porque una canción que no se puede etiquetar
/// sigue siendo una canción que querés escuchar.
pub fn leer(ruta: &Path) -> Pista {
    let archivo = lofty::read_from_path(ruta).ok();

    let duration_secs = archivo
        .as_ref()
        .map(|a| a.properties().duration().as_secs());

    let crudos = match archivo.as_ref().and_then(tag_principal) {
        Some(tag) => Crudos {
            title: tag.title().map(|t| t.into_owned()),
            artist: tag.artist().map(|a| a.into_owned()),
            album: tag.album().map(|a| a.into_owned()),
            year: anio_crudo(tag),
            track_number: tag.track(),
            duration_secs,
        },
        None => Crudos {
            duration_secs,
            ..Crudos::default()
        },
    };

    desde_partes(ruta, crudos)
}

/// El tag preferido del formato, o el primero que haya si no hay uno primario.
fn tag_principal(archivo: &lofty::file::TaggedFile) -> Option<&Tag> {
    archivo.primary_tag().or_else(|| archivo.first_tag())
}

/// El año tal como está escrito en el tag, sin interpretar.
///
/// Los FLAC de Vorbis suelen traer `DATE` (una fecha completa) y los MP3 con
/// ID3v2 pueden traer `TYER` (solo el año), así que probamos los dos.
fn anio_crudo(tag: &Tag) -> Option<String> {
    tag.get_string(ItemKey::Year)
        .or_else(|| tag.get_string(ItemKey::RecordingDate))
        .map(str::to_owned)
}
