#!/usr/bin/env bash
# Registra los servidores MCP de usuario de Claude Code. Viven en
# ~/.claude.json, que es estado y queda fuera del repo: no se puede enlazar.
#
# pi/mcp.json declara los que Pi también le pasa a Claude Code (engram y
# context7); mcp.json, los que sólo usa Claude Code. Linear entra por acá
# porque en Pi lo provee el paquete pi-linear.
#
#   claude/mcp.sh    agrega los que faltan; los ya registrados no se tocan

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$HOME/.claude.json"
FAILED=()

declared() {
    jq -s 'map(.mcpServers) | add' "$HERE/../pi/mcp.json" "$HERE/mcp.json"
}

registered() {
    jq -e --arg name "$1" '.mcpServers[$name]' "$STATE" >/dev/null 2>&1
}

register() {
    claude mcp add-json --scope user "$1" "$2" >/dev/null 2>&1 || FAILED+=("$1")
}

servers="$(declared)"

for name in $(jq -r 'keys[]' <<<"$servers"); do
    registered "$name" || register "$name" "$(jq -c --arg name "$name" '.[$name]' <<<"$servers")"
done

if ((${#FAILED[@]})); then
    printf 'falló: %s\n' "${FAILED[@]}" >&2
    exit 1
fi
