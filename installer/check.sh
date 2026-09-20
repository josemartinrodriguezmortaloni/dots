#!/usr/bin/env bash
# Gate del instalador: tests, lints y complejidad ciclomática (< 4).
# lizard sale con código 1 en cuanto una función pasa de CCN 3.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

cargo test --quiet
cargo clippy --all-targets --quiet -- -D warnings
uvx lizard -C 3 -l rust src
