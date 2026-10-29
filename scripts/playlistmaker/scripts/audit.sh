#!/usr/bin/env bash
# ./scripts/audit.sh
# Install cargo-audit on first use.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
if ! command -v cargo-audit >/dev/null 2>&1; then
	printf 'cargo-audit not found - installing (one-time)...\n'
	cargo install --locked cargo-audit
fi

cargo audit --deny warnings
