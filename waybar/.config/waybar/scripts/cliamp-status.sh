#!/usr/bin/env bash
#
# cliamp-status.sh — helper de Waybar para cliamp.
#
# Lee el estado por el IPC de cliamp (`cliamp status --json`) y devuelve JSON
# para Waybar (return-type: json) con: text, tooltip, class y alt.
#
# Modos (primer argumento):
#   now-playing (default) -> "<música>  Título — Artista" para el módulo de info.
#   playpause             -> ícono ⏸/▶ según el estado, para el botón play/pause.
#
# Los glyphs (Nerd Font / Material Design) se generan por codepoint con $'\U'
# para no depender de pegar caracteres del Private Use Area (que se pierden al
# editar). La clase (playing/paused/stopped) se usa para estilar en style.css.

mode="${1:-now-playing}"

  icon_music=$'\U000f075a'   # ♫  music (nf-md-music, doble nota)
icon_play=$'\U000f040a'    # 󰐊  play
icon_pause=$'\U000f03e4'   # 󰏤  pause

status="$(cliamp status --json 2>/dev/null)"

# Estado actual: playing | paused | stopped (vacío o ok!=true => stopped).
state="stopped"
if [[ -n "$status" ]]; then
  s="$(jq -r 'if .ok == true then (.state // "stopped") else "stopped" end' <<<"$status" 2>/dev/null)"
  [[ -n "$s" ]] && state="$s"
fi

case "$mode" in
  playpause)
    # El botón muestra la ACCIÓN: si suena => ⏸ (pausar); si no => ▶ (reanudar).
    if [[ "$state" == "playing" ]]; then
      icon="$icon_pause"
    else
      icon="$icon_play"
    fi
    jq -cn --arg t "$icon" --arg c "$state" \
      '{text: $t, class: $c, alt: $c, tooltip: "Play / Pause"}'
    ;;

  *)
    # now-playing: pista actual con prefijo de música, o solo el ícono si no hay nada.
    if [[ -z "$status" ]]; then
      jq -cn --arg ic "$icon_music" \
        '{text: $ic, class: "stopped", alt: "stopped", tooltip: "Abrir cliamp para elegir música"}'
      exit 0
    fi

    out="$(
      jq -c --arg ic "$icon_music" '
        if (.ok != true) or ((.track.title // "") == "") then
          {text: $ic, class: "stopped", alt: "stopped",
           tooltip: "Abrir cliamp para elegir música"}
        else
          {
            text: (.track.title
                   + (if ((.track.artist // "") != "")
                        then "  —  " + .track.artist else "" end)),
            tooltip: ((.track.artist // "Desconocido") + "\n" + .track.title
                      + (if (.total // 0) > 0
                           then "\n\nPista \((.index + 1)) / \(.total)" else "" end)),
            class: (.state // "playing"),
            alt: (.state // "playing")
          }
        end
      ' <<<"$status" 2>/dev/null
    )"

    [[ -z "$out" ]] && out="$(jq -cn --arg ic "$icon_music" '{text:$ic,class:"stopped",alt:"stopped"}')"
    echo "$out"
    ;;
esac
