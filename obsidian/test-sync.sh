#!/usr/bin/env bash
# Suite de tests para sync.sh: dos bóvedas temporales contra un remoto bare.
#
# Uso: bash test-sync.sh [ruta-al-script]
# Exit 0 si toda la suite pasa; 1 si hay al menos un fallo.

set -uo pipefail

SCRIPT="$(realpath "${1:-$(dirname "$0")/sync.sh}")"

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

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

REMOTE="$TMP/remote.git"
A="$TMP/a"
B="$TMP/b"
NOTES="$TMP/notifications"

# Entorno aislado: sin la config global de git ni notificaciones reales.
export GIT_CONFIG_GLOBAL="$TMP/gitconfig"
export OBSIDIAN_REMOTE="$REMOTE"
git config --global user.email test@example.com
git config --global user.name test
git config --global init.defaultBranch main
mkdir "$TMP/bin"
printf '#!/bin/sh\nprintf "%%s\\n" "$*" >>"%s"\n' "$NOTES" >"$TMP/bin/notify-send"
chmod +x "$TMP/bin/notify-send"
export PATH="$TMP/bin:$PATH"

sync_once() { bash "$SCRIPT" --once "$1" >/dev/null 2>&1; }
tracked() { git -C "$1" ls-files --error-unmatch -- "$2" >/dev/null 2>&1; }
untracked() { ! tracked "$@"; }
commits() { git -C "$1" rev-list --count HEAD; }
remote_has() { git -C "$REMOTE" cat-file -e "main:$1" 2>/dev/null; }
remote_head() { git -C "$REMOTE" rev-parse main; }
rebasing() { [[ -d "$A/.git/rebase-merge" || -d "$A/.git/rebase-apply" ]]; }
notified() { grep -q "$1" "$NOTES" 2>/dev/null; }

# ─── Bóveda A con historia propia, publicada en el remoto ───────────────────
git init -q --bare "$REMOTE"
git init -q "$A"
printf '.venv/\n.obsidian/workspace*.json\n' >"$A/.gitignore"
git -C "$A" add .gitignore
git -C "$A" commit -q -m init
git -C "$A" remote add origin "$REMOTE"
git -C "$A" push -q -u origin main

mkdir -p "$A/notas" "$A/.obsidian" "$A/roam/psicologa" "$A/.venv" "$A/code" "$A/anidado"
printf 'hola\n' >"$A/notas/nota.md"
printf 'raíz\n' >"$A/raíz con espacios.md"
printf 'rara\n' >"$A/notas/*glob:rara.md"
printf '%%PDF\n' >"$A/notas/apunte.pdf"
truncate -s 6M "$A/notas/video.mp4"
printf '{}\n' >"$A/.obsidian/app.json"
printf '{}\n' >"$A/.obsidian/workspace.json"
printf 'privado\n' >"$A/roam/psicologa/sesion.md"
printf 'x\n' >"$A/.venv/lib.py"
printf '*.class\n' >"$A/code/.gitignore"
printf 'bytecode\n' >"$A/code/Main.class"
git -C "$A/anidado" init -q
printf 'sub\n' >"$A/anidado/sub.md"

# ─── Commit y push de lo que corresponde ────────────────────────────────────
sync_once "$A"
check "commitea en la primera corrida"               test "$(commits "$A")" = 2
check "pushea el commit al remoto"                   test "$(remote_head)" = "$(git -C "$A" rev-parse HEAD)"
check "versiona notas .md"                           tracked "$A" "notas/nota.md"
check "versiona .md en la raíz con espacios"         tracked "$A" "raíz con espacios.md"
check "versiona nombres con caracteres de pathspec"  tracked "$A" "notas/*glob:rara.md"
check "versiona binarios chicos"                     tracked "$A" "notas/apunte.pdf"
check "versiona la config de .obsidian"              tracked "$A" ".obsidian/app.json"
check "no versiona archivos de 5 MB o más"           untracked "$A" "notas/video.mp4"
check "nunca versiona roam/psicologa"                untracked "$A" "roam/psicologa/sesion.md"
check "respeta el .gitignore de la bóveda"           untracked "$A" ".venv/lib.py"
check "respeta los .gitignore anidados"              untracked "$A" "code/Main.class"
check "no versiona repos anidados"                   untracked "$A" "anidado"
check "el mensaje lleva el hostname"                 grep -q "^auto($(hostname)): " <<<"$(git -C "$A" log -1 --format=%s)"
check "psicologa no llega al remoto"                 bash -c "! git -C '$REMOTE' log --all --format= --name-only | grep -q psicologa"

# ─── Sin cambios reales: no hay commit ──────────────────────────────────────
touch "$A/notas/nota.md"
sync_once "$A"
check "un touch no hace fallar el ciclo"             test $? = 0
check "no commitea sin cambios de contenido"         test "$(commits "$A")" = 2

# ─── Segundo equipo: clona y recibe cambios ─────────────────────────────────
sync_once "$B"
check "clona la bóveda si no existe"                 test -f "$B/notas/nota.md"

printf 'desde b\n' >>"$B/notas/nota.md"
rm "$B/raíz con espacios.md"
sync_once "$B"
check "pushea una modificación del otro equipo"      remote_has "notas/nota.md"
check "pushea un borrado"                            bash -c "! git -C '$REMOTE' cat-file -e 'main:raíz con espacios.md' 2>/dev/null"

sync_once "$A"
check "trae los cambios del otro equipo"             test "$(tail -1 "$A/notas/nota.md")" = "desde b"
check "aplica el borrado remoto"                     test ! -e "$A/raíz con espacios.md"

# ─── Conflicto: pausa, notifica y no pushea ─────────────────────────────────
printf 'b gana\n' >"$B/notas/nota.md"
sync_once "$B"
before=$(remote_head)
printf 'a pierde\n' >"$A/notas/nota.md"
sync_once "$A"
check "notifica el conflicto"                        notified "Conflicto"
check "no pushea con conflicto"                      test "$(remote_head)" = "$before"
check "aborta el rebase"                             bash -c "! { [ -d '$A/.git/rebase-merge' ] || [ -d '$A/.git/rebase-apply' ]; }"
check "conserva el cambio local"                  test "$(cat "$A/notas/nota.md")" = "a pierde"

# ─── Resolución a mano: el sync no interfiere y después retoma ──────────────
git -C "$A" pull -q --rebase >/dev/null 2>&1
check "el pull a mano deja un rebase en curso"       rebasing
printf 'otra\n' >"$A/notas/otra.md"
sync_once "$A"
check "no commitea durante un rebase a mano"         untracked "$A" "notas/otra.md"
check "no toca el rebase a mano"                     rebasing

printf 'resuelto\n' >"$A/notas/nota.md"
git -C "$A" add notas/nota.md
GIT_EDITOR=true git -C "$A" rebase --continue >/dev/null 2>&1
sync_once "$A"
check "retoma el sync tras resolver"                 test "$(git -C "$REMOTE" show main:notas/nota.md)" = "resuelto"
check "pushea lo acumulado durante la pausa"         remote_has "notas/otra.md"

# ─── Bóvedas con otra historia: no las toca ─────────────────────────────────
C="$TMP/c"
git init -q "$C"
printf 'local\n' >"$C/nota.md"
git -C "$C" add nota.md
git -C "$C" commit -q -m local
bash "$SCRIPT" --once "$C" 2>/dev/null
check "sale con 3 ante otra historia"                test $? = 3
check "notifica la otra historia"                    notified "otra historia"
check "no commitea en una bóveda ajena"              test "$(commits "$C")" = 1

D="$TMP/d"
mkdir "$D"
printf 'suelta\n' >"$D/nota.md"
bash "$SCRIPT" --once "$D" 2>/dev/null
check "sale con 3 si la bóveda no es un repo"        test $? = 3

# ─── Resultado ──────────────────────────────────────────────────────────────
printf '%d/%d OK\n' "$pass" "$((pass + fail))"
for f in "${FAILURES[@]}"; do printf '  FALLA: %s\n' "$f"; done
[ "$fail" -eq 0 ]
