#!/usr/bin/env bash
#
# cliamp-open.sh — abre (o enfoca) cliamp dentro de una sesión de tmux dedicada,
# con los colores del tema de Omarchy.
#
# 1) Regenera el tema "omarchy" de cliamp con los colores actuales y lo fija.
# 2) Si ya hay una ventana de cliamp abierta, la enfoca; si no, abre una terminal
#    nueva (app-id org.omarchy.cliamp) que arranca cliamp dentro de tmux.

dir="$(dirname "$(readlink -f "$0")")"

"$dir/cliamp-omarchy-theme.sh" >/dev/null 2>&1

cfg="$HOME/.config/cliamp/config.toml"
[[ -f "$cfg" ]] && sed -i 's/^theme[[:space:]]*=.*/theme = "omarchy"/' "$cfg"

exec omarchy-launch-or-focus "org.omarchy.cliamp" \
  "uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.cliamp -e $dir/cliamp-tmux.sh"
