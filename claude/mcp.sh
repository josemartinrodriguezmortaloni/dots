#!/usr/bin/env bash
# Registra los servidores MCP de usuario de Claude Code. Viven en
# ~/.claude.json, que es estado y queda fuera del repo: no se puede enlazar.
#
# mcp.json los declara. En Pi, los paquetes gentle-engram y context7-pi
# proveen engram y context7.
#
#   claude/mcp.sh    agrega los que faltan; los ya registrados no se tocan

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$HOME/.claude.json"
FAILED=()

declared() {
    jq '.mcpServers' "$HERE/mcp.json"
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
