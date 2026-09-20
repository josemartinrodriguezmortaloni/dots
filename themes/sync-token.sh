#!/usr/bin/env bash
# Re-copies the Token Meridian files that Omarchy stages verbatim.
#
# omarchy-theme-set-templates only generates a file the theme does not already
# ship, so every file copied here replaces the 26-colour approximation Omarchy
# would otherwise derive from colors.toml. The copies carry upstream's
# "Do not edit manually" header: edit Token and re-run this, never the copies.
#
# colors.toml, neovim.lua, vscode.json, icons.theme and preview.png are written
# by hand and are not touched here.
set -euo pipefail

REPO_URL="https://github.com/ThorstenRhau/token.git"
THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_DIR="$(cd "$THEMES_DIR/.." && pwd)/vscode/token-vscode-themes"

copy_variant() {
    local contrib="$1" dest="$2" variant="$3"

    install -Dm644 "$contrib/ghostty/token-meridian-$variant" "$dest/ghostty.conf"
    install -Dm644 "$contrib/kitty/token-meridian-$variant.conf" "$dest/kitty.conf"
    install -Dm644 "$contrib/pi/token-meridian-$variant.json" "$dest/pi.json"
    install -Dm644 "$contrib/obsidian/token-meridian/theme.css" "$dest/obsidian.css"
}

# Vendored so install.sh can link it into ~/.vscode/extensions on any machine:
# the extension is not on the marketplace, and omarchy-theme-set-vscode's
# --install-extension fails silently when it is missing.
copy_vscode_extension() {
    local contrib="$1"

    rm -rf "$VSCODE_DIR"
    mkdir -p "$VSCODE_DIR"
    cp "$contrib/vscode/package.json" "$VSCODE_DIR/package.json"
    cp -r "$contrib/vscode/themes" "$VSCODE_DIR/themes"
}

# Global so the EXIT trap still resolves it once main's scope is gone.
TMP_DIR=""
cleanup() { [[ -n $TMP_DIR ]] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

main() {
    local tmp
    tmp="$(mktemp -d)"
    TMP_DIR="$tmp"

    git clone --depth 1 "$REPO_URL" "$tmp/token" >/dev/null 2>&1

    copy_variant "$tmp/token/contrib" "$THEMES_DIR/token-meridian" dark
    copy_variant "$tmp/token/contrib" "$THEMES_DIR/token-meridian-light" light
    copy_vscode_extension "$tmp/token/contrib"

    git -C "$tmp/token" rev-parse HEAD >"$THEMES_DIR/TOKEN_VERSION"
    echo "Token synced at $(cat "$THEMES_DIR/TOKEN_VERSION")"
}

main "$@"
