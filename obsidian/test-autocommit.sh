#!/usr/bin/env bash
# Suite de tests para autocommit.sh sobre una bóveda temporal.
#
# Uso: bash test-autocommit.sh [ruta-al-script]
# Exit 0 si toda la suite pasa; 1 si hay al menos un fallo.

set -uo pipefail

SCRIPT="$(realpath "${1:-$(dirname "$0")/autocommit.sh}")"

pass=0
fail=0
declare -a FAILURES=()

# check <descripción> <comando...>
check() {
  local desc="$1"
  shift
  if "$@"; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    FAILURES+=("$desc")
  fi
}

tracked() { git -C "$VAULT" ls-files --error-unmatch -- "$1" >/dev/null 2>&1; }
untracked() { ! tracked "$1"; }
commits() { git -C "$VAULT" rev-list --count HEAD 2>/dev/null || echo 0; }
autocommit() { bash "$SCRIPT" "$VAULT"; }

VAULT=$(mktemp -d)
trap 'rm -rf "$VAULT"' EXIT

git -C "$VAULT" init -q -b main
git -C "$VAULT" config user.email test@example.com
git -C "$VAULT" config user.name test
printf '*\n' >"$VAULT/.gitignore"

mkdir -p "$VAULT/notas" "$VAULT/.obsidian" "$VAULT/code/gradle/wrapper" "$VAULT/code/tools"
printf 'hola\n' >"$VAULT/notas/nota.md"
printf 'raíz\n' >"$VAULT/raíz con espacios.md"
printf '{}\n' >"$VAULT/.obsidian/app.json"
printf '{}\n' >"$VAULT/.obsidian/workspace.json"
printf '%%PDF\n' >"$VAULT/notas/apunte.pdf"
printf '!gradle/wrapper/gradle-wrapper.jar\n' >"$VAULT/code/.gitignore"
printf 'jar\n' >"$VAULT/code/gradle/wrapper/gradle-wrapper.jar"
printf 'readme\n' >"$VAULT/code/tools/README.md"
printf 'rara\n' >"$VAULT/notas/*glob:rara.md"

# ─── Primer commit: sólo la lista blanca ─────────────────────────────────────
autocommit
check "commitea en la primera corrida"              test "$(commits)" = 1
check "versiona notas .md"                          tracked "notas/nota.md"
check "versiona .md en la raíz con espacios"        tracked "raíz con espacios.md"
check "versiona nombres con caracteres de pathspec" tracked "notas/*glob:rara.md"
check "versiona la config de .obsidian"             tracked ".obsidian/app.json"
check "no versiona workspace.json"                  untracked ".obsidian/workspace.json"
check "no versiona binarios"                        untracked "notas/apunte.pdf"
check "ignora la negación de un .gitignore anidado" untracked "code/gradle/wrapper/gradle-wrapper.jar"
check "no versiona .gitignore anidados"             untracked "code/.gitignore"
check "no versiona carpetas tools/"                 untracked "code/tools/README.md"

# ─── Sin cambios: no hay commit ──────────────────────────────────────────────
autocommit
check "no commitea sin cambios"                     test "$(commits)" = 1

printf 'otro\n' >"$VAULT/notas/apunte2.pdf"
autocommit
check "un binario nuevo no genera commit"           test "$(commits)" = 1

# ─── Modificar y borrar ─────────────────────────────────────────────────────
printf 'chau\n' >>"$VAULT/notas/nota.md"
autocommit
check "commitea una modificación"                   test "$(commits)" = 2
check "el contenido modificado queda en HEAD"       test "$(git -C "$VAULT" show HEAD:notas/nota.md | tail -1)" = "chau"

rm "$VAULT/raíz con espacios.md"
autocommit
check "commitea un borrado"                         test "$(commits)" = 3
check "la nota borrada sale del índice"             untracked "raíz con espacios.md"

# ─── Resultado ──────────────────────────────────────────────────────────────
printf '%d/%d OK\n' "$pass" "$((pass + fail))"
for f in "${FAILURES[@]}"; do printf '  FALLA: %s\n' "$f"; done
[ "$fail" -eq 0 ]
