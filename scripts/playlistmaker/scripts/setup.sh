#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# 1. Hooks de git
git config core.hooksPath .githooks
chmod +x .githooks/*

# 2. Herramienas de cargo
# cargo install --locked beacon cargo-audit

# 3. Servicios (cuando existan)
# [[ -f .env ]] || cp .env.example .env
# docker compose up -d

echo "✓ Listo. Arrancá con: ./scripts/dev.sh"
