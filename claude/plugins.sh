#!/usr/bin/env bash
# Instala los marketplaces y plugins que declara settings.json. Claude Code
# guarda la lista ahí pero no la instala en una máquina nueva: lo instalado vive
# en ~/.claude/plugins, que es estado y queda fuera del repo.
#
#   claude/plugins.sh    agrega lo que falta; lo ya instalado no se toca

set -euo pipefail

SETTINGS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/settings.json"
FAILED=()

# Líneas de $1 que no aparecen en $2.
missing() {
    grep -vxF -f <(printf '%s\n' "$2") <<<"$1" || true
}

source_of() {
    jq -r --arg name "$1" '.extraKnownMarketplaces[$name].source | .repo // .path // .url' "$SETTINGS"
}

add_marketplaces() {
    local declared known name
    declared=$(jq -r '.extraKnownMarketplaces // {} | keys[]' "$SETTINGS")
    known=$(claude plugin marketplace list --json | jq -r '.[].name')

    for name in $(missing "$declared" "$known"); do
        claude plugin marketplace add "$(source_of "$name")" >/dev/null 2>&1 || FAILED+=("marketplace $name")
    done
}

install_plugins() {
    local enabled installed id
    enabled=$(jq -r '.enabledPlugins // {} | to_entries[] | select(.value) | .key' "$SETTINGS")
    installed=$(claude plugin list --json | jq -r '.[].id')

    for id in $(missing "$enabled" "$installed"); do
        claude plugin install "$id" </dev/null >/dev/null 2>&1 || FAILED+=("plugin $id")
    done
}

add_marketplaces
install_plugins

if ((${#FAILED[@]})); then
    printf 'falló: %s\n' "${FAILED[@]}" >&2
    exit 1
fi
