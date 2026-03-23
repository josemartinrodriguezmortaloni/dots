# dotfiles

Personal dotfiles for Arch Linux (Omarchy) with Hyprland, Vesper theme, and modern CLI tools.

## What's included

| Config | Description |
|--------|-------------|
| **nvim** | Neovim 0.11+ with vesper.nvim, blink.cmp, mini.nvim, treesitter, diffview |
| **doom** | Doom Emacs — init.el, config.el, packages.el con org-roam, magit, LSP |
| **ghostty** | Ghostty terminal with Vesper colors, JetBrainsMono Nerd Font |
| **hypr** | Hyprland compositor — keybindings, animations, dual monitor, NVIDIA |
| **waybar** | Status bar with custom window pill, workspace indicators |
| **walker** | App launcher config |
| **tmux** | Tmux with C-Space prefix, vi mode, Vesper theme |
| **zsh** | Zsh with Zinit, oh-my-posh (star theme), fzf-tab, syntax highlighting |
| **ohmyposh** | Oh-My-Posh prompt theme |
| **vesper** | Omarchy Vesper theme — Mellow base + Vesper accents (bdsqqq style) |

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

```bash
git clone https://github.com/josemartinrodriguezmortaloni/dots.git ~/Work/dots
cd ~/Work/dots
chmod +x install.sh
./install.sh
```

The installer creates symlinks from this repo to `~/.config/` and `~/`. Existing files are backed up to `~/.dotfiles-backup/<timestamp>/` before being replaced.

## System

- **OS**: Arch Linux (Omarchy)
- **WM**: Hyprland (Wayland)
- **Terminal**: Ghostty
- **Shell**: Zsh + Zinit + oh-my-posh
- **Editor**: Neovim 0.11+ / Doom Emacs
- **Font**: JetBrainsMono Nerd Font
- **GPU**: NVIDIA
- **Monitors**: Ultrawide 3440x1440 + 1080p
