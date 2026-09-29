# dotfiles

Personal dotfiles for Arch Linux (Omarchy Quattro) with Hyprland. Terminal, editor, bar and
multiplexer take their colors from the active Omarchy theme, so switching the theme recolors
everything.

## Modules

Each module is a set of symlinks from this repo to `~/`. Pick them in the installer TUI.

| Module | Links | Notes |
|--------|-------|-------|
| **nvim** | `~/.config/nvim` | Neovim 0.11+: blink.cmp, mini.nvim, treesitter, snacks, toggleterm; hot-reloads the Omarchy theme |
| **ghostty** | `~/.config/ghostty/config` | Colors come from the active theme's `ghostty.conf` |
| **hypr** | `~/.config/hypr/*.lua`, `*.conf` | Omarchy Quattro Lua overrides; the monitor profile depends on the machine (see [Install](#install)) |
| **waybar** | `~/.config/waybar` | Custom window pill, workspace indicators, cliamp status |
| **tmux** | `~/.config/tmux/tmux.conf` | C-Space prefix, vi mode |
| **zsh** | `~/.zshrc`, `~/.zshenv` | Zinit, fzf-tab, syntax highlighting |
| **ohmyposh** | `~/.config/ohmyposh/star.omp.json` | Prompt theme `star` |
| **themes** | `~/.config/omarchy/themes/*` | Omarchy themes (see [Themes](#themes)) and the matching VS Code extension |
| **omarchy** | `~/.config/omarchy/{hooks,extensions,shell.toml}` | `theme-set` hook (tmux/nvim), Quattro menu look, wallpaper pool shared by every theme |
| **claude** | `~/.claude/{CLAUDE.md,settings.json,…}` | Claude Code global config and own skills; installs the plugins declared in `settings.json` |
| **obsidian** | `~/.local/bin/obsidian-autocommit`, systemd user units | Timer that commits the text of the local vault `~/Documents/Obsidian` every 15 min |

`zed/` holds the Zed settings, keymap and themes; the installer does not link it.

The Obsidian vault is not in this repo: this repo is public and the notes are private. Only the
versioning mechanism lives here. The vault's git repo is local, has no remote, and tracks only
text (`.md`, `.canvas`, `.base`, `.excalidraw`, `.puml`, `.obsidian/`); `obsidian/autocommit.sh`
holds that list.

## Themes

| Theme | Source |
|-------|--------|
| `token-meridian`, `token-meridian-light` | [Token](https://github.com/ThorstenRhau/token) by ThorstenRhau. `themes/sync-token.sh` re-copies the upstream files at the commit pinned in `themes/TOKEN_VERSION`; edit Token, never the copies |
| `industrial` | Instrumental brutalism from SimPlant: neutral greys, red for errors, amber for progress. Spec in [`themes/industrial/DESIGN.md`](themes/industrial/DESIGN.md) |

`themes/make-preview.sh` regenerates each theme's `preview.png`.

## Install

Requires `cargo`: the installer is a Rust/ratatui TUI under [`installer/`](installer/) and
`install.sh` only compiles and runs it. On Arch: `sudo pacman -S rust`.

```bash
git clone https://github.com/josemartinrodriguezmortaloni/dots.git ~/Work/dots
cd ~/Work/dots
./install.sh                          # asks the machine, then the TUI
./install.sh --help                   # list the modules
DOTS_MACHINE=desktop ./install.sh --all   # every module, no questions
```

`install.sh` asks which machine it runs on, because only the monitor layout differs. The answer
picks the profile linked as `~/.config/hypr/monitors.lua`. Export `DOTS_MACHINE` to skip the
question.

| `DOTS_MACHINE` | Profile | Monitors |
|----------------|---------|----------|
| `desktop` | `hypr/monitors-esc.lua` | Samsung 3440x1440@100 + Samsung 1080p rotated |
| `notebook` | `hypr/monitors.lua` | Internal panel `eDP-1` 1080p |

The installer shows every existing file it is about to displace and waits for confirmation; those
files are moved to `~/.dotfiles-backup/<timestamp>/` before being replaced. After linking it runs
each installed module's hook: reload Hyprland, restart Waybar, apply the `theme-set` hook, install
the Claude Code plugins, and enable the Obsidian timer.

## Development

| Command | Checks |
|---------|--------|
| `installer/check.sh` | Installer tests, clippy, cyclomatic complexity < 4 |
| `bash claude/hooks/test-guard-bash.sh` | Bash guard hook for Claude Code |
| `bash obsidian/test-autocommit.sh` | Vault autocommit on a temporary repo |

## System

- **OS**: Arch Linux (Omarchy)
- **WM**: Hyprland (Wayland)
- **Terminal**: Ghostty
- **Shell**: Zsh + Zinit + oh-my-posh
- **Editor**: Neovim 0.11+
- **GPU**: NVIDIA GeForce RTX 2060 SUPER (desktop)
