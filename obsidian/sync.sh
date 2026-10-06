#!/usr/bin/env bash
# Sincroniza la bóveda Obsidian con GitHub: commitea y pushea los cambios
# locales y trae los que otro equipo pusheó. Lo corre obsidian-sync.service.
#
#   obsidian-sync [bóveda]          vigila la bóveda y sincroniza
#   obsidian-sync --once [bóveda]   un solo ciclo de sincronización
#
# Por defecto la bóveda es ~/Documents/Obsidian. Qué se versiona lo deciden el
# .gitignore de la bóveda (directorios de build y entornos) y este script:
# PRIVATE nunca entra y ningún archivo de MAX_BYTES o más tampoco, porque
# GitHub rechaza archivos de más de 100 MB y git guarda completa cada versión
# de un binario.

set -euo pipefail

REMOTE="${OBSIDIAN_REMOTE:-https://github.com/josemartinrodriguezmortaloni/obsidian-vault.git}"
PRIVATE="roam/psicologa"
MAX_BYTES=$((5 * 1024 * 1024))

# Obsidian guarda cada ~2 s mientras escribís: se commitea tras QUIET segundos
# sin cambios. GitHub no avisa de pushes ajenos: se consulta cada PULL_EVERY.
QUIET=30
PULL_EVERY=120

# systemd no reinicia el servicio con este código: una bóveda con otra
# historia necesita que la unifiques a mano.
UNRELATED=3

SCOPE=(. ":(exclude)$PRIVATE")
WATCH_EXCLUDE="(^|/)\.git(/|$)|/$PRIVATE(/|$)"

DIRTY=1
LAST_SYNC=0
WARNED=""

log() { printf '%s\n' "$*" >&2; }

# Sin daemon de notificaciones (antes del login gráfico) queda el journal.
notify() {
    log "$1"
    notify-send -u critical "Obsidian sync" "$1" 2>/dev/null || true
}

prepare() {
    [[ -e "$VAULT" ]] || git clone -q "$REMOTE" "$VAULT"
    cd "$VAULT"
    attach
}

# Una bóveda que ya existía sólo se sincroniza si desciende del remoto.
attach() {
    git rev-parse --verify -q HEAD >/dev/null || refuse "$VAULT no es un repo git con commits"
    ensure_origin
    git fetch -q origin
    git merge-base HEAD origin/main >/dev/null || refuse "$VAULT tiene otra historia que $REMOTE: unificalas a mano"
    # Con nombre explícito: durante un rebase a mano HEAD no está en una rama.
    git branch -q --set-upstream-to=origin/main main
}

ensure_origin() {
    git remote get-url origin >/dev/null 2>&1 || git remote add origin "$REMOTE"
}

refuse() {
    notify "$1"
    exit "$UNRELATED"
}

# Un rebase o merge a mano en curso: commitear encima rompería tu resolución.
busy() {
    local path
    for path in rebase-merge rebase-apply MERGE_HEAD; do
        [[ -e "$(git rev-parse --git-path "$path")" ]] && return 0
    done
    return 1
}

sync() {
    busy && return 0
    commit_changes
    pull || return 0
    push
}

commit_changes() {
    local changes
    changes="$(git rev-parse --git-path obsidian-sync.changes)"
    candidates >"$changes"
    [[ -s "$changes" ]] || return 0

    git --literal-pathspecs add -A --pathspec-from-file="$changes" --pathspec-file-nul
    git commit -q -m "auto($(hostname)): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

# Borrados, más nuevos y modificados que pasan el filtro de tamaño.
candidates() {
    git ls-files -z --deleted -- "${SCOPE[@]}"
    git ls-files -z --others --modified --exclude-standard -- "${SCOPE[@]}" | regular_under_limit
}

# `-type f` descarta los repos anidados, que `ls-files` lista como `dir/`. Los
# borrados no existen y `find` los reporta: ya entran por `--deleted`.
regular_under_limit() {
    # shellcheck disable=SC2185 # -files0-from excluye rutas en la línea de comandos
    find -files0-from - -maxdepth 0 -type f -size "-${MAX_BYTES}c" -print0 2>/dev/null || true
}

pull() {
    git pull -q --rebase --autostash && return 0
    # Sin rebase en curso falló la red: se reintenta en el próximo ciclo.
    busy || return 1
    git rebase --abort
    warn_conflict
    return 1
}

warn_conflict() {
    local remote
    remote="$(git rev-parse origin/main)"
    [[ "$remote" == "$WARNED" ]] && return 0
    WARNED="$remote"
    notify "Conflicto con origin/main: resolvelo con 'git pull --rebase' en $VAULT. El sync queda en pausa hasta entonces."
}

push() {
    [[ -n "$(git rev-list '@{u}..HEAD')" ]] || return 0
    git push -q origin HEAD:main || log "push falló: se reintenta en el próximo ciclo"
}

watch() {
    local status
    while true; do
        status=0
        read -r -t "$QUIET" _ || status=$?
        on_read "$status"
    done < <(inotifywait -m -r -q -e close_write,create,delete,move \
        --exclude "$WATCH_EXCLUDE" --format . "$VAULT")
}

# `read` devuelve 0 con un evento, 1 si inotifywait murió y > 128 al vencer QUIET.
on_read() {
    case "$1" in
        0) DIRTY=1 ;;
        1) exit 1 ;;
        *) on_quiet ;;
    esac
}

on_quiet() {
    (( DIRTY || SECONDS - LAST_SYNC >= PULL_EVERY )) || return 0
    sync
    DIRTY=0
    LAST_SYNC=$SECONDS
}

main() {
    local mode=watch
    if [[ "${1:-}" == --once ]]; then
        mode=sync
        shift
    fi
    VAULT="${1:-$HOME/Documents/Obsidian}"

    prepare
    "$mode"
}

main "$@"
