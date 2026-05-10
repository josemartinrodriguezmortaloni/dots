#!/usr/bin/env bash
# ─── dotfiles installer ───────────────────────────────────────────────────────
# Interactive TUI to pick which modules to symlink into ~/.config and ~/.
# Existing files get backed up to ~/.dotfiles-backup/<timestamp>/ before replace.

set -euo pipefail
shopt -s nullglob

# ─── Paths ────────────────────────────────────────────────────────────────────

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# ─── Vesper/Mellow palette (truecolor) ────────────────────────────────────────

FG=$'\e[38;2;255;199;153m'       # #FFC799 accent
MUTED=$'\e[38;2;126;126;126m'    # #7E7E7E
RED=$'\e[38;2;245;161;145m'      # #f5a191
GREEN=$'\e[38;2;144;185;159m'    # #90b99f
YELLOW=$'\e[38;2;230;185;157m'   # #e6b99d
BLUE=$'\e[38;2;172;161;207m'     # #aca1cf
WHITE=$'\e[38;2;255;255;255m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
RESET=$'\e[0m'

# ─── Module registry ──────────────────────────────────────────────────────────
# Parallel arrays. Each key "foo" expects a function install_foo defined below.

MODULE_KEYS=(
    nvim
    ghostty
    hypr
    waybar
    walker
    tmux
    zsh
    ohmyposh
    doom
    vesper
)

MODULE_DESCS=(
    "Neovim 0.11+ with Vesper theme"
    "Ghostty terminal emulator"
    "Hyprland compositor configs"
    "Waybar status bar with window pill"
    "Walker app launcher"
    "Tmux with C-Space prefix"
    "Zsh + Zinit + oh-my-posh"
    "Oh-My-Posh star prompt theme"
    "Doom Emacs config"
    "Omarchy Vesper theme"
)

# Selection state — 1 = selected, 0 = not. Default: all on.
SELECTED=()
for ((i = 0; i < ${#MODULE_KEYS[@]}; i++)); do SELECTED[i]=1; done

# Global counters written to by _link().
LINKED=0
BACKED=0

# Return value for TUI helpers.
TUI_CHOICE=""

# ─── Print helpers ────────────────────────────────────────────────────────────

_info() { printf "  %sℹ%s %s\n" "$BLUE" "$RESET" "$*"; }
_ok()   { printf "  %s✓%s %s\n" "$GREEN" "$RESET" "$*"; }
_warn() { printf "  %s⚠%s %s\n" "$YELLOW" "$RESET" "$*"; }
_err()  { printf "  %s✗%s %s\n" "$RED" "$RESET" "$*" >&2; exit 1; }
_dim()  { printf "  %s%s%s\n" "$DIM" "$*" "$RESET"; }

# ─── Symlink helper ───────────────────────────────────────────────────────────
# _link <src> <dest>
#   - no-op if dest is already the correct symlink
#   - backs up existing file/dir/link to $BACKUP preserving relative path
#   - creates the symlink

_link() {
    local src="$1" dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        return 0
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP"
        local rel="${dest#$HOME/}"
        mkdir -p "$BACKUP/$(dirname "$rel")"
        mv "$dest" "$BACKUP/$rel"
        BACKED=$((BACKED + 1))
    fi

    ln -sf "$src" "$dest"
    LINKED=$((LINKED + 1))
}

# ─── Module installers ────────────────────────────────────────────────────────

install_nvim()     { _link "$DOTS/nvim"            "$HOME/.config/nvim"; }
install_ghostty()  { _link "$DOTS/ghostty/config"  "$HOME/.config/ghostty/config"; }

install_hypr() {
    local f
    for f in "$DOTS"/hypr/*.conf; do
        _link "$f" "$HOME/.config/hypr/$(basename "$f")"
    done
}

install_waybar() {
    _link "$DOTS/waybar/config.jsonc"   "$HOME/.config/waybar/config.jsonc"
    _link "$DOTS/waybar/style.css"      "$HOME/.config/waybar/style.css"
    _link "$DOTS/waybar/window_pill.py" "$HOME/.config/waybar/window_pill.py"
}

install_walker()   { _link "$DOTS/walker/config.toml"     "$HOME/.config/walker/config.toml"; }
install_tmux()     { _link "$DOTS/tmux/tmux.conf"         "$HOME/.config/tmux/tmux.conf"; }

install_zsh() {
    _link "$DOTS/zsh/.zshrc"  "$HOME/.zshrc"
    _link "$DOTS/zsh/.zshenv" "$HOME/.zshenv"
}

install_ohmyposh() { _link "$DOTS/ohmyposh/star.omp.json" "$HOME/.config/ohmyposh/star.omp.json"; }

install_doom() {
    _link "$DOTS/doom/init.el"     "$HOME/.config/doom/init.el"
    _link "$DOTS/doom/config.el"   "$HOME/.config/doom/config.el"
    _link "$DOTS/doom/packages.el" "$HOME/.config/doom/packages.el"
}

install_vesper()   { _link "$DOTS/vesper" "$HOME/.config/omarchy/themes/vesper"; }

# ─── TUI primitives ───────────────────────────────────────────────────────────

_banner() {
    printf '\n'
    printf "  %s%s╭──────────────────────────────────────────────╮%s\n"      "$FG" "$BOLD" "$RESET"
    printf "  %s%s│%s  %s%sdotfiles%s  %s·%s  %svesper + mellow%s                %s%s│%s\n" \
        "$FG" "$BOLD" "$RESET" "$WHITE" "$BOLD" "$RESET" "$DIM" "$RESET" "$MUTED" "$RESET" "$FG" "$BOLD" "$RESET"
    printf "  %s%s╰──────────────────────────────────────────────╯%s\n"      "$FG" "$BOLD" "$RESET"
    printf '\n'
}

# Read one keystroke. Handles arrow keys (ESC [ A/B/C/D) as a single token.
_read_key() {
    local key rest
    IFS= read -rsn1 key || key=""
    if [[ $key == $'\e' ]]; then
        IFS= read -rsn2 -t 0.01 rest 2>/dev/null || rest=""
        key+="$rest"
    fi
    printf '%s' "$key"
}

# tui_choose "Label 1" "Label 2" ...
#   Single-selection menu. Sets TUI_CHOICE to 0-indexed result, or 255 if quit.
tui_choose() {
    local options=("$@")
    local n=${#options[@]}
    local cursor=0
    local i key

    tput civis
    printf "  %s↑/↓ navigate · enter confirm · q quit%s\n\n" "$DIM" "$RESET"

    for ((i = 0; i < n; i++)); do _draw_choose_line "$i" "$cursor" "${options[i]}"; done

    while true; do
        key="$(_read_key)"
        case "$key" in
            $'\e[A' | 'k') cursor=$(((cursor - 1 + n) % n)) ;;
            $'\e[B' | 'j') cursor=$(((cursor + 1) % n)) ;;
            '')            TUI_CHOICE=$cursor; tput cnorm; return 0 ;;
            'q' | 'Q')     TUI_CHOICE=255;     tput cnorm; return 0 ;;
            *)             continue ;;
        esac

        printf '\e[%dA\e[J' "$n"
        for ((i = 0; i < n; i++)); do _draw_choose_line "$i" "$cursor" "${options[i]}"; done
    done
}

_draw_choose_line() {
    local idx="$1" cursor="$2" label="$3"
    local marker=' ' color_open="$WHITE"

    if [ "$idx" -eq "$cursor" ]; then
        marker="${FG}❯${RESET}"
        color_open="${FG}${BOLD}"
    fi

    printf "   %b %b%s%b\n" "$marker" "$color_open" "$label" "$RESET"
}

# tui_multiselect — edits SELECTED[] in place. Sets TUI_CHOICE=255 on quit, else 0.
tui_multiselect() {
    local n=${#MODULE_KEYS[@]}
    local cursor=0
    local i key

    tput civis
    printf "  %s↑/↓ navigate · space toggle · a all · n none · enter confirm · q quit%s\n\n" "$DIM" "$RESET"

    for ((i = 0; i < n; i++)); do _draw_module_line "$i" "$cursor"; done

    while true; do
        key="$(_read_key)"
        case "$key" in
            $'\e[A' | 'k') cursor=$(((cursor - 1 + n) % n)) ;;
            $'\e[B' | 'j') cursor=$(((cursor + 1) % n)) ;;
            ' ')           SELECTED[cursor]=$((1 - SELECTED[cursor])) ;;
            'a' | 'A')     for ((i = 0; i < n; i++)); do SELECTED[i]=1; done ;;
            'n' | 'N')     for ((i = 0; i < n; i++)); do SELECTED[i]=0; done ;;
            '')            TUI_CHOICE=0;   tput cnorm; return 0 ;;
            'q' | 'Q')     TUI_CHOICE=255; tput cnorm; return 0 ;;
            *)             continue ;;
        esac

        printf '\e[%dA\e[J' "$n"
        for ((i = 0; i < n; i++)); do _draw_module_line "$i" "$cursor"; done
    done
}

_draw_module_line() {
    local idx="$1" cursor="$2"
    local key="${MODULE_KEYS[idx]}"
    local desc="${MODULE_DESCS[idx]}"
    local marker=' ' color_open="$WHITE" checkbox

    if [ "$idx" -eq "$cursor" ]; then
        marker="${FG}❯${RESET}"
        color_open="${FG}${BOLD}"
    fi

    if [ "${SELECTED[idx]}" -eq 1 ]; then
        checkbox="${GREEN}●${RESET}"
    else
        checkbox="${MUTED}○${RESET}"
    fi

    printf "   %b %b %b%-10s%s %s%s%s\n" \
        "$marker" "$checkbox" "$color_open" "$key" "$RESET" "$DIM" "$desc" "$RESET"
}

# ─── Orchestration ────────────────────────────────────────────────────────────

install_selected() {
    local total=0 s
    for s in "${SELECTED[@]}"; do [ "$s" -eq 1 ] && total=$((total + 1)); done

    if [ "$total" -eq 0 ]; then
        _warn "no modules selected, nothing to do"
        return 0
    fi

    printf "\n  %s%s▸ installing %d module(s)…%s\n\n" "$FG" "$BOLD" "$total" "$RESET"

    local idx=0 i key before_l before_b did_l did_b
    for ((i = 0; i < ${#MODULE_KEYS[@]}; i++)); do
        [ "${SELECTED[i]}" -eq 1 ] || continue
        idx=$((idx + 1))
        key="${MODULE_KEYS[i]}"
        before_l=$LINKED
        before_b=$BACKED

        printf "  %s[%d/%d]%s %s%-10s%s  " \
            "$DIM" "$idx" "$total" "$RESET" "$WHITE" "$key" "$RESET"

        if "install_$key"; then
            did_l=$((LINKED - before_l))
            did_b=$((BACKED - before_b))

            if [ "$did_l" -eq 0 ] && [ "$did_b" -eq 0 ]; then
                printf "%salready linked%s\n" "$DIM" "$RESET"
            else
                printf "%s✓%s %s%d linked" "$GREEN" "$RESET" "$DIM" "$did_l"
                [ "$did_b" -gt 0 ] && printf " · %d backed up" "$did_b"
                printf "%s\n" "$RESET"
            fi
        else
            printf "%s✗ failed%s\n" "$RED" "$RESET"
        fi
    done
}

post_install() {
    local need_hypr=0 need_waybar=0 hint_doom=0 hint_shell=0 i

    for ((i = 0; i < ${#MODULE_KEYS[@]}; i++)); do
        [ "${SELECTED[i]}" -eq 1 ] || continue
        case "${MODULE_KEYS[i]}" in
            hypr)      need_hypr=1 ;;
            waybar)    need_waybar=1 ;;
            doom)      hint_doom=1 ;;
            zsh | tmux) hint_shell=1 ;;
        esac
    done

    printf '\n'

    if [ "$need_hypr" -eq 1 ] && command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 && _ok "hyprland reloaded"
    fi

    if [ "$need_waybar" -eq 1 ] && command -v omarchy-restart-waybar >/dev/null 2>&1; then
        omarchy-restart-waybar >/dev/null 2>&1 && _ok "waybar restarted"
    fi

    [ "$hint_doom"  -eq 1 ] && _info "run ${BOLD}doom sync${RESET} to apply emacs package changes"
    [ "$hint_shell" -eq 1 ] && _info "open a new terminal to pick up zsh/tmux changes"
}

print_summary() {
    printf '\n'
    printf "  %s──────────────────────────────────────────%s\n" "$MUTED" "$RESET"
    printf "  %s%s%d symlink(s) created%s" "$GREEN" "$BOLD" "$LINKED" "$RESET"
    if [ "$BACKED" -gt 0 ]; then
        printf " %s·%s %s%d backed up%s" "$DIM" "$RESET" "$YELLOW" "$BACKED" "$RESET"
    fi
    printf '\n'
    if [ "$BACKED" -gt 0 ]; then
        printf "  %sbackup → %s%s\n" "$DIM" "$BACKUP" "$RESET"
    fi
    printf "  %s──────────────────────────────────────────%s\n\n" "$MUTED" "$RESET"
}

# ─── Cleanup on exit ──────────────────────────────────────────────────────────

_cleanup() { tput cnorm 2>/dev/null || true; }
trap '_cleanup' EXIT
trap '_cleanup; printf "\n  %saborted%s\n\n" "$RED" "$RESET"; exit 130' INT TERM

# ─── Help ─────────────────────────────────────────────────────────────────────

_print_help() {
    printf '\n  %s%sdotfiles installer%s\n' "$WHITE" "$BOLD" "$RESET"
    printf '  %ssymlink module configs into their expected locations%s\n\n' "$DIM" "$RESET"
    printf '  %s%sUSAGE%s\n'   "$WHITE" "$BOLD" "$RESET"
    printf '    ./install.sh [OPTIONS]\n\n'
    printf '  %s%sOPTIONS%s\n' "$WHITE" "$BOLD" "$RESET"
    printf '    %s-a, --all%s     install all modules non-interactively\n' "$FG" "$RESET"
    printf '    %s-h, --help%s    show this help\n\n'                       "$FG" "$RESET"
    printf '  %s%sMODULES%s\n'  "$WHITE" "$BOLD" "$RESET"
    local i
    for ((i = 0; i < ${#MODULE_KEYS[@]}; i++)); do
        printf "    %s%-10s%s %s%s%s\n" "$FG" "${MODULE_KEYS[i]}" "$RESET" "$DIM" "${MODULE_DESCS[i]}" "$RESET"
    done
    printf '\n'
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    local mode="interactive"

    while [ $# -gt 0 ]; do
        case "$1" in
            -a | --all)  mode="all" ;;
            -h | --help) _print_help; exit 0 ;;
            *)           _err "unknown option: $1" ;;
        esac
        shift
    done

    if [ "$mode" = "interactive" ] && { [ ! -t 0 ] || [ ! -t 1 ]; }; then
        _err "not a tty — use ${BOLD}--all${RESET} for non-interactive install"
    fi

    _banner

    if [ "$mode" = "all" ]; then
        for ((i = 0; i < ${#MODULE_KEYS[@]}; i++)); do SELECTED[i]=1; done
    else
        tui_choose "Install all modules" "Select modules to install" "Cancel"

        case "$TUI_CHOICE" in
            0)
                for ((i = 0; i < ${#MODULE_KEYS[@]}; i++)); do SELECTED[i]=1; done
                printf '\n'
                ;;
            1)
                printf '\n'
                tui_multiselect
                if [ "$TUI_CHOICE" = "255" ]; then
                    _dim "cancelled."
                    exit 0
                fi
                ;;
            2 | 255)
                _dim "cancelled."
                exit 0
                ;;
        esac
    fi

    install_selected
    post_install
    print_summary
}

main "$@"
