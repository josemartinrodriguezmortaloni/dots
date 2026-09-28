#!/usr/bin/env bash
# Commitea los cambios de texto de la bóveda Obsidian. Lo corre
# obsidian-autocommit.timer; el repo es local y no tiene remoto.
#
#   obsidian-autocommit [bóveda]    por defecto ~/Documents/Obsidian
#
# Qué se versiona lo decide VERSIONED, no .gitignore: los proyectos de código
# anidados en la bóveda traen sus propios .gitignore y sus negaciones
# (!gradle-wrapper.jar) le ganan a las reglas de la raíz. `git add -f` sobre
# esta lista hace que esos archivos no cuenten.

set -euo pipefail

VAULT="${1:-$HOME/Documents/Obsidian}"

VERSIONED=(
    ':(glob)**/*.md'
    ':(glob)**/*.canvas'
    ':(glob)**/*.base'
    ':(glob)**/*.excalidraw'
    ':(glob)**/*.puml'
    ':(glob).obsidian/**'
    ':(exclude,glob).obsidian/workspace*.json'
    ':(exclude,glob)**/tools/**'
    ':(exclude,glob)**/node_modules/**'
    ':(exclude,glob).trash/**'
)

cd "$VAULT"

changes=$(mktemp)
trap 'rm -f "$changes"' EXIT

git ls-files -z --others --modified --deleted -- "${VERSIONED[@]}" >"$changes"

# Sin rutas, `git add -A` tomaría el árbol entero.
[[ -s "$changes" ]] || exit 0

git --literal-pathspecs add -A -f --pathspec-from-file="$changes" --pathspec-file-nul
git commit -q -m "auto: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
