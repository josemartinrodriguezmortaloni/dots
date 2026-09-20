#!/usr/bin/env bash
# ─── dotfiles installer ───────────────────────────────────────────────────────
# Bootstrap del instalador. La lógica vive en installer/ (Rust + ratatui): el
# catálogo de módulos, los symlinks con respaldo, la TUI y los hooks.
#
#   ./install.sh          TUI interactiva
#   ./install.sh --all    instala todo sin TUI
#   ./install.sh --help   lista los módulos

set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY="$DOTS/installer/target/release/dots-install"

# El binario resuelve las rutas del repositorio a partir de esta variable: vive
# bajo installer/target/ y deducir la raíz desde su propia ruta se rompe en
# cuanto cargo cambia el layout de salida.
export DOTS_ROOT="$DOTS"

if ! command -v cargo >/dev/null 2>&1; then
    printf '\n  cargo no está instalado.\n  instalalo con: sudo pacman -S rust\n\n' >&2
    exit 1
fi

# cargo ya decide por sí solo si hay algo que recompilar; comparar mtimes a mano
# sería reimplementar peor lo que su caché incremental hace bien.
if [ -t 1 ]; then printf '  compilando el instalador…\r'; fi
cargo build --release --quiet --manifest-path "$DOTS/installer/Cargo.toml"
if [ -t 1 ]; then printf '                            \r'; fi

exec "$BINARY" "$@"
