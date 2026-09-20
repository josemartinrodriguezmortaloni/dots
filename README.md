# dotfiles

Personal dotfiles for Arch Linux (Omarchy) with Hyprland, Vesper theme, and modern CLI tools.

## What's included

| Config | Description |
|--------|-------------|
| **nvim** | Neovim 0.11+ with vesper.nvim, blink.cmp, mini.nvim, treesitter, diffview |
| **ghostty** | Ghostty terminal with Vesper colors, JetBrainsMono Nerd Font |
| **hypr** | Hyprland (Omarchy Quattro Lua) — overrides for monitors, input, look, cliamp |
| **waybar** | Status bar with custom window pill, workspace indicators |
| **tmux** | Tmux with C-Space prefix, vi mode, Vesper theme |
| **zsh** | Zsh with Zinit, oh-my-posh (star theme), fzf-tab, syntax highlighting |
| **ohmyposh** | Oh-My-Posh prompt theme |
| **vesper** | Omarchy Vesper theme — Mellow base + Vesper accents (bdsqqq style) |
| **omarchy** | `theme-set` hook (tmux/nvim), `shell.toml` (Walker look on the Quattro menu), `omarchy-menu.jsonc` |

## Color palette

Based on [bdsqqq's Mellow + Vesper hybrid](https://bedes.qui.gg/writing/macos-rice):

```
bg: #101010    fg: #ffffff    accent: #FFC799

Normal                    Bright
black   #101010           #7E7E7E
red     #f5a191           #ff8080
green   #90b99f           #99FFE4
yellow  #e6b99d           #FFC799
blue    #aca1cf           #b9aeda
magenta #e29eca           #ecaad6
cyan    #ea83a5           #f591b2
white   #A0A0A0           #ffffff
```

## Install

Requires `cargo`: the installer is a Rust/ratatui TUI under [`installer/`](installer/) and
`install.sh` only compiles and runs it. On Arch: `sudo pacman -S rust`.

```bash
git clone https://github.com/josemartinrodriguezmortaloni/dots.git ~/Work/dots
cd ~/Work/dots
chmod +x install.sh
./install.sh            # TUI: pick modules, confirm, install
./install.sh --all      # every module, no TUI
./install.sh --help     # list the modules
```

The installer creates symlinks from this repo to `~/.config/` and `~/`. It shows every existing
file it is about to displace and waits for confirmation; those files are moved to
`~/.dotfiles-backup/<timestamp>/` before being replaced. Colors come from the active Omarchy
theme via `omarchy-theme-color`, falling back to `themes/token-meridian/`.

Run `installer/check.sh` to gate a change: tests, clippy and cyclomatic complexity.

## System

- **OS**: Arch Linux (Omarchy)
- **WM**: Hyprland (Wayland)
- **Terminal**: Ghostty
- **Shell**: Zsh + Zinit + oh-my-posh
- **Editor**: Neovim 0.11+
- **Font**: JetBrainsMono Nerd Font
- **GPU**: NVIDIA
- **Monitors**: Ultrawide 3440x1440 + 1080p
