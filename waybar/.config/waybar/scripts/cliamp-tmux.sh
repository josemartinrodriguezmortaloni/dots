#!/usr/bin/env bash
#
# cliamp-tmux.sh — corre cliamp dentro de una sesión de tmux dedicada.
#
# Usa "attach-or-create" (-A): si la sesión "cliamp" ya existe (p. ej. cerraste la
# ventana sin salir de cliamp), se reengancha y la música sigue sonando; si no,
# la crea y arranca cliamp en ~/Music. Al salir de cliamp con q, la sesión se
# cierra sola.

exec tmux new-session -A -s cliamp "cliamp '$HOME/Music'"
