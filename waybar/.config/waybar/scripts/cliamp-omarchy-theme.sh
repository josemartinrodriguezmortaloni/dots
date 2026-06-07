#!/usr/bin/env bash
#
# cliamp-omarchy-theme.sh — genera un tema de cliamp a partir del tema actual de
# Omarchy, para que cliamp combine con el resto del escritorio.
#
# Lee   ~/.config/omarchy/current/theme/colors.toml
# Crea  ~/.config/cliamp/themes/omarchy.toml  (accent/bright_fg/fg/green/yellow/red)
#
# Si cliamp está corriendo, recarga el tema en vivo por IPC (sirve también cuando
# cliamp corre dentro de tmux, sin necesidad de reabrirlo).

colors="$HOME/.config/omarchy/current/theme/colors.toml"
dest_dir="$HOME/.config/cliamp/themes"
dest="$dest_dir/omarchy.toml"

[[ -f "$colors" ]] || { echo "cliamp-omarchy-theme: falta $colors" >&2; exit 1; }
mkdir -p "$dest_dir"

python3 - "$colors" "$dest" <<'PY'
import sys, tomllib

src, dest = sys.argv[1], sys.argv[2]
with open(src, "rb") as f:
    c = tomllib.load(f)

def pick(*keys, default="#000000"):
    for k in keys:
        v = c.get(k)
        if v:
            return v
    return default

# Mapeo Omarchy -> cliamp. accent y foreground son semánticos en Omarchy;
# el resto sigue la convención ANSI (color8=muted, color1/2/3=red/green/yellow).
theme = {
    "accent":    pick("accent", "color2"),       # título, barra de progreso, selección
    "bright_fg": pick("foreground", "color15"),  # texto principal, reloj
    "fg":        pick("color8", "color6"),        # texto secundario/inactivo
    "green":     pick("color2"),                  # indicador play, volumen, spectrum bajo
    "yellow":    pick("color3"),                  # spectrum medio
    "red":       pick("color1"),                  # spectrum alto, errores
}

with open(dest, "w") as f:
    for k, v in theme.items():
        f.write(f'{k} = "{v}"\n')

print("cliamp-omarchy-theme: generado", dest)
for k, v in theme.items():
    print(f"  {k} = {v}")
PY

# Recargar en vivo si hay una instancia de cliamp corriendo.
if pgrep -x cliamp >/dev/null 2>&1; then
  cliamp theme omarchy >/dev/null 2>&1 && echo "cliamp-omarchy-theme: tema recargado en vivo" || true
fi
