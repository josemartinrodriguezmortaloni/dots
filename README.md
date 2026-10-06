```
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀
 ⠀⠀⠀⣠⣤⣶⣶⣶⣤⡀⣸⣿⣿⡟⠀⠀⠀⠀⠀⠀
 ⠀⢠⣾⣿⣿⣿⠿⠿⢿⣷⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀          Arch Linux dotfiles. One Omarchy theme recolors everything.
 ⠀⣾⣿⣿⠏⠀⠀⠀⠀⢹⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀
 ⢸⣿⣿⣿⠀⠀⠀⠀⠀⣸⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀          git clone https://github.com/josemartinrodriguezmortaloni/dots ~/Work/dots
 ⣼⣿⣿⡏⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀
 ⣿⣿⣿⡇⠀⠀⠀⠀⢰⣿⣿⣿⠁⠀⠀⢀⣠⣤⣀⠀          ⚠ Status: personal config. Read a module before you link it.
 ⢿⣿⣿⣿⣦⣤⣤⣶⣿⣿⣿⡿⠀⠀⠀⣾⣿⣿⣿⡆
 ⠈⠻⢿⣿⣿⣿⠿⠋⢾⣿⣿⠇⠀⠀⠀⠘⠻⠿⠛⠀
```

dots is the configuration of my Arch Linux machines: Hyprland on Omarchy Quattro, Neovim, Ghostty, tmux and Zsh, plus the Pi coding agent and a service that syncs my Obsidian vault with GitHub. A Rust installer links each module into `~/` and backs up every file it replaces. Terminal, editor, bar and multiplexer read their colors from the active Omarchy theme.

## Highlights

- **One theme switch:** Ghostty, Neovim, tmux, Waybar and Zathura follow the active Omarchy theme; Neovim reloads it live
- **Safe installer:** a Rust/ratatui TUI that lists every file it displaces and moves it to `~/.dotfiles-backup/<timestamp>/`
- **Per machine:** desktop and notebook share everything except the monitor layout
- **Agents and notes:** Pi config with a command guard and the pi-statusline package, and a git sync service for the Obsidian vault

<p>
  <a href="https://archlinux.org"><img alt="Arch Linux" src="https://img.shields.io/badge/ARCH-LINUX-0a0a0a.svg?style=for-the-badge&amp;logo=archlinux&amp;labelColor=000000" height="28"></a>
  <a href="https://omarchy.org"><img alt="Omarchy Quattro" src="https://img.shields.io/badge/OMARCHY-QUATTRO-0a0a0a.svg?style=for-the-badge&amp;labelColor=000000" height="28"></a>
  <a href="https://hypr.land"><img alt="Hyprland" src="https://img.shields.io/badge/HYPRLAND-LUA-0a0a0a.svg?style=for-the-badge&amp;logo=hyprland&amp;labelColor=000000" height="28"></a>
  <a href="https://github.com/josemartinrodriguezmortaloni/dots/commits/main"><img alt="Last commit" src="https://img.shields.io/github/last-commit/josemartinrodriguezmortaloni/dots.svg?style=for-the-badge&amp;labelColor=000000" height="28"></a>
</p>

## Install

The installer needs `cargo`: `install.sh` only compiles and runs the TUI under [`installer/`](installer/). On Arch: `sudo pacman -S rust`.

```bash
git clone https://github.com/josemartinrodriguezmortaloni/dots.git ~/Work/dots
cd ~/Work/dots
./install.sh
```

## Get started

`install.sh` opens the TUI: it asks which machine it runs on, then lets you pick modules:

```bash
./install.sh                              # TUI: machine question, then modules
./install.sh --help                       # list the modules
DOTS_MACHINE=desktop ./install.sh --all   # every module, no questions; DOTS_MACHINE is required
```

After linking, the installer runs the hook of each installed module: reload Hyprland, restart Waybar, apply the `theme-set` hook, enable the Obsidian sync service, and run `mise install`.

## Modules

Each module is a set of symlinks from this repo to `~/`.

| Module       | Links                                                  | Notes                                                                                             |
| ------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| **nvim**     | `~/.config/nvim`                                       | Neovim 0.11+: blink.cmp, mini.nvim, treesitter, snacks, toggleterm; hot-reloads the Omarchy theme |
| **ghostty**  | `~/.config/ghostty/config`                             | Colors come from the active theme's `ghostty.conf`                                                |
| **hypr**     | `~/.config/hypr/*.lua`, `*.conf`                       | Omarchy Quattro Lua overrides; the monitor profile depends on the machine                         |
| **waybar**   | `~/.config/waybar`                                     | Custom window pill, workspace indicators, cliamp status                                           |
| **tmux**     | `~/.config/tmux/tmux.conf`                             | C-Space prefix, vi mode                                                                           |
| **zathura**  | `~/.config/zathura`, `~/.config/omarchy/themed/zathura.tpl` | Floating glass PDF viewer; Omarchy renders the colors from the active theme                  |
| **zsh**      | `~/.zshrc`, `~/.zshenv`                                | Zinit, fzf-tab, syntax highlighting                                                               |
| **ohmyposh** | `~/.config/ohmyposh/star.omp.json`                     | Prompt theme `star`                                                                               |
| **themes**   | `~/.config/omarchy/themes/*`                           | Omarchy themes and the matching VS Code extension                                                 |
| **omarchy**  | `~/.config/omarchy/{hooks,extensions,shell.toml}`      | `theme-set` hook (tmux/nvim), Quattro menu look, wallpaper pool shared by every theme             |
| **pi**       | `~/.pi/agent/{AGENTS.md,settings.json,mcp.json,statusline.json,skills/*,extensions/*}`, `~/.claude/settings.json` | Pi instructions, packages, MCP servers, statusline layout, own skills, the `guard` extension; Claude Code settings with the claude.ai-synced plugins off; removes the old `~/.claude` links |
| **obsidian** | `~/.local/bin/obsidian-sync`, systemd user service     | Commits, pushes and pulls the vault `~/Documents/Obsidian` on every change                        |
| **mise**     | `~/.config/mise/config.toml`                           | Global tools (claude, codex, gh, node, pi); runs `mise install` so every machine gets the same paths |

`zed/` holds the Zed settings, keymap and themes; the installer does not link it.

## Machines

The answer to the machine question picks the profile linked as `~/.config/hypr/monitors.lua`. Export `DOTS_MACHINE` to skip the question; `--all` requires it.

| `DOTS_MACHINE` | Profile                 | Monitors                                      |
| -------------- | ----------------------- | --------------------------------------------- |
| `desktop`      | `hypr/monitors-esc.lua` | Samsung 3440x1440@100 + Samsung 1080p rotated |
| `notebook`     | `hypr/monitors.lua`     | Internal panel `eDP-1` 1080p                  |

## Themes

| Theme                                    | Source                                                                                                                                                  |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `token-meridian`, `token-meridian-light` | [Token](https://github.com/ThorstenRhau/token). `themes/sync-token.sh` re-copies the upstream files at the commit pinned in `themes/TOKEN_VERSION`      |
| `industrial`                             | CIA screens from The Amateur (2025): near-black canvas, lime accent, red, amber, orange and teal signals. Spec in [`themes/industrial/DESIGN.md`](themes/industrial/DESIGN.md) |

Edit Token upstream and re-run `themes/sync-token.sh`; never edit the copies. `themes/make-preview.sh` regenerates each theme's `preview.png`.

## Obsidian vault

The vault is not in this repo: this repo is public and the notes are private. Only the sync mechanism lives here. The vault syncs with the private repo `obsidian-vault` on GitHub through [`obsidian/sync.sh`](obsidian/sync.sh), which `obsidian-sync.service` runs:

- **Push:** `inotifywait` watches the vault. After 30 s without changes, the script commits, pulls with rebase, and pushes.
- **Pull:** the script pulls at start, before each push, and every 2 min. GitHub does not notify other machines of a push.
- **Scope:** every file below 5 MB, except `roam/psicologa` and the paths in the vault's `.gitignore` (build directories and environments). GitHub rejects files over 100 MB.
- **Conflict:** the script aborts the rebase, sends a notification, and stops pushing. It resumes when you resolve with `git pull --rebase` in the vault.
- **New machine:** the script clones the vault when `~/Documents/Obsidian` does not exist. It refuses a vault with unrelated history and exits with code 3; merge it by hand once.

## Development

Gate every change before a commit:

| Command                                              | Checks                                             |
| ---------------------------------------------------- | -------------------------------------------------- |
| `installer/check.sh`                                 | Installer tests, clippy, cyclomatic complexity < 4 |
| `bash pi/extensions/guard/test-guard-bash.sh`        | Shell risk rules of the Pi guard                   |
| `node --test pi/extensions/*/*.test.ts`              | Pi `guard` votes (Node 24+)                        |
| `bash obsidian/test-sync.sh`                         | Vault sync between two clones and a bare remote    |

## System

- **OS**: Arch Linux (Omarchy)
- **WM**: Hyprland (Wayland)
- **Terminal**: Ghostty
- **Shell**: Zsh + Zinit + oh-my-posh
- **Editor**: Neovim 0.11+
- **GPU**: NVIDIA GeForce RTX 2060 SUPER (desktop)

## Credits

Built on [Omarchy](https://omarchy.org). The Token Meridian themes come from [Token](https://github.com/ThorstenRhau/token) by ThorstenRhau.
