#!/usr/bin/env bash
set -euo pipefail

# ─── Dotfiles installer ──────────────────────────────────────────────────────
# Symlinks configs from this repo to their expected locations.
# Existing files are backed up to ~/.dotfiles-backup/<timestamp>/

DOTS="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
LINKED=0
BACKED=0

# ─── Helpers ──────────────────────────────────────────────────────────────────

info() { printf "\033[1;34m[info]\033[0m  %s\n" "$1"; }
ok() { printf "\033[1;32m[ok]\033[0m    %s\n" "$1"; }
warn() { printf "\033[1;33m[warn]\033[0m  %s\n" "$1"; }
err() {
	printf "\033[1;31m[error]\033[0m %s\n" "$1"
	exit 1
}

backup_and_link() {
	local src="$1" dest="$2"

	mkdir -p "$(dirname "$dest")"

	# Already linked correctly
	if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
		ok "$dest (already linked)"
		return
	fi

	# Backup existing file/dir
	if [ -e "$dest" ] || [ -L "$dest" ]; then
		mkdir -p "$BACKUP"
		local rel="${dest#$HOME/}"
		mkdir -p "$BACKUP/$(dirname "$rel")"
		mv "$dest" "$BACKUP/$rel"
		warn "backed up $dest"
		((BACKED++))
	fi

	ln -sf "$src" "$dest"
	ok "$dest -> $src"
	((LINKED++))
}

link_dir() {
	local src="$1" dest="$2"

	mkdir -p "$(dirname "$dest")"

	if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
		ok "$dest (already linked)"
		return
	fi

	if [ -e "$dest" ] || [ -L "$dest" ]; then
		mkdir -p "$BACKUP"
		local rel="${dest#$HOME/}"
		mkdir -p "$BACKUP/$(dirname "$rel")"
		mv "$dest" "$BACKUP/$rel"
		warn "backed up $dest"
		((BACKED++))
	fi

	ln -sf "$src" "$dest"
	ok "$dest -> $src"
	((LINKED++))
}

# ─── Main ─────────────────────────────────────────────────────────────────────

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║         dotfiles installer           ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# Neovim
info "neovim"
link_dir "$DOTS/nvim" "$HOME/.config/nvim"

# Ghostty
info "ghostty"
backup_and_link "$DOTS/ghostty/config" "$HOME/.config/ghostty/config"

# Hyprland
info "hyprland"
for f in "$DOTS"/hypr/*.conf; do
	backup_and_link "$f" "$HOME/.config/hypr/$(basename "$f")"
done

# Waybar
info "waybar"
backup_and_link "$DOTS/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
backup_and_link "$DOTS/waybar/style.css" "$HOME/.config/waybar/style.css"
backup_and_link "$DOTS/waybar/window_pill.py" "$HOME/.config/waybar/window_pill.py"

# Walker
info "walker"
backup_and_link "$DOTS/walker/config.toml" "$HOME/.config/walker/config.toml"

# Tmux
info "tmux"
backup_and_link "$DOTS/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Zsh
info "zsh"
backup_and_link "$DOTS/zsh/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTS/zsh/.zshenv" "$HOME/.zshenv"

# Oh-My-Posh
info "oh-my-posh"
backup_and_link "$DOTS/ohmyposh/star.omp.json" "$HOME/.config/ohmyposh/star.omp.json"

# Vesper theme (Omarchy)
info "vesper theme"
link_dir "$DOTS/vesper" "$HOME/.config/omarchy/themes/vesper"

# ─── Post-install ─────────────────────────────────────────────────────────────

echo ""
echo "  ──────────────────────────────────────"
printf "  \033[1;32m%d symlinks created\033[0m" "$LINKED"
if [ "$BACKED" -gt 0 ]; then
	printf ", \033[1;33m%d files backed up\033[0m to %s" "$BACKED" "$BACKUP"
fi
echo ""
echo "  ──────────────────────────────────────"
echo ""

# Reload services if available
if command -v hyprctl &>/dev/null; then
	info "reloading hyprland..."
	hyprctl reload &>/dev/null && ok "hyprland reloaded"
fi

if command -v omarchy-restart-waybar &>/dev/null; then
	info "restarting waybar..."
	omarchy-restart-waybar &>/dev/null && ok "waybar restarted"
fi

echo ""
info "done! open a new terminal to pick up zsh/tmux changes."
