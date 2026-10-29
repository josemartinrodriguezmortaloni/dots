#!/usr/bin/env bash
# Serve the LiquidAI LFM3 models with one llama-server router on the LAN
# (OpenAI-compatible API). Each client picks a model with the "model" field:
# lfm3-1.7b or lfm3-omni (see presets.ini). One model is in VRAM at a time;
# a request for the other model swaps it in.
#
# Usage: lfm3-server.sh [extra llama-server args...]
#   lfm3-server.sh             # first run downloads the models
#   lfm3-server.sh --offline   # cache only, no network
#
# Environment:
#   LFM3_HOST     listen address        (default: 0.0.0.0, every interface)
#   LFM3_PORT     listen port           (default: 8080)
#   LFM3_API_KEY  require this API key  (default: unset, no auth)

set -euo pipefail

readonly HOST="${LFM3_HOST:-0.0.0.0}"
readonly PORT="${LFM3_PORT:-8080}"
readonly PRESETS="$(dirname "$(realpath "$0")")/presets.ini"

lan_url() {
    local ip
    ip=$(ip -4 -o route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "src") print $(i + 1)}')
    echo "http://${ip:-localhost}:${PORT}/v1"
}

auth_flags() {
    [[ -n "${LFM3_API_KEY:-}" ]] && echo "--api-key ${LFM3_API_KEY}"
    return 0
}

main() {
    echo "lfm3-server: $(lan_url) (models: lfm3-1.7b, lfm3-omni)" >&2

    # shellcheck disable=SC2046 # word splitting of the flag string is intended.
    exec llama-server \
        --models-preset "$PRESETS" \
        --models-max 1 \
        --host "$HOST" --port "$PORT" \
        $(auth_flags) \
        "$@"
}

main "$@"
