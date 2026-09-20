#!/usr/bin/env bash
# Renders each theme's preview.png from its own colors.toml.
#
# omarchy-theme-switcher shows preview.png in the theme picker; without one the
# theme appears blank next to the stock themes. Replace the output with a real
# desktop screenshot whenever you want one -- nothing else reads this file.
set -euo pipefail

THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWATCH_KEYS=(
    red yellow orange green cyan blue magenta brown
    bright_red bright_yellow bright_green bright_cyan
    bright_blue bright_magenta accent muted
)
SWATCH=56
GAP=8
MARGIN=24
TOP=70
# ImageMagick here ships no font configuration (`magick -list font` is empty),
# so the title needs an explicit font file.
FONT="$(fc-match -f '%{file}' sans-serif)"

toml_value() {
    sed -nE "s/^$2 = \"(#[0-9a-fA-F]{6})\"$/\1/p" "$1"
}

swatch_draw() {
    local index="$1" color="$2" x y

    x=$((MARGIN + (index % 8) * (SWATCH + GAP)))
    y=$((TOP + (index / 8) * (SWATCH + GAP)))
    printf -- '-fill\n%s\n-draw\nrectangle %d,%d %d,%d\n' \
        "$color" "$x" "$y" "$((x + SWATCH))" "$((y + SWATCH))"
}

render_preview() {
    local dir="$1" title="$2" colors="$1/colors.toml"
    local -a args=()
    local index key

    for index in "${!SWATCH_KEYS[@]}"; do
        key="${SWATCH_KEYS[$index]}"
        mapfile -t -O "${#args[@]}" args < <(swatch_draw "$index" "$(toml_value "$colors" "$key")")
    done

    magick -size 552x214 "xc:$(toml_value "$colors" background)" \
        -font "$FONT" -fill "$(toml_value "$colors" foreground)" \
        -pointsize 22 -annotate +24+48 "$title" \
        "${args[@]}" "$dir/preview.png"
}

render_preview "$THEMES_DIR/token-meridian" "Token Meridian"
render_preview "$THEMES_DIR/token-meridian-light" "Token Meridian Light"
echo "previews written"
