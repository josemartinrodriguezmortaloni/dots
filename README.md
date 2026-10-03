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

dots is the configuration of my Arch Linux machines: Hyprland on Omarchy Quattro, Neovim, Ghostty, tmux and Zsh, plus the Pi coding agent and a timer that versions my Obsidian vault. A Rust installer links each module into `~/` and backs up every file it replaces. Terminal, editor, bar and multiplexer read their colors from the active Omarchy theme.

## Highlights

- **One theme switch:** Ghostty, Neovim, tmux and Waybar follow the active Omarchy theme; Neovim reloads it live
- **Safe installer:** a Rust/ratatui TUI that lists every file it displaces and moves it to `~/.dotfiles-backup/<timestamp>/`
- **Per machine:** desktop and notebook share everything except the monitor layout
- **Agents and notes:** Pi config with a command guard and the pi-statusline package, and a local git timer for the Obsidian vault

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

After linking, the installer runs the hook of each installed module: reload Hyprland, restart Waybar, apply the `theme-set` hook, enable the Obsidian timer, and run `mise install`.

## Modules

Each module is a set of symlinks from this repo to `~/`.

| Module       | Links                                                  | Notes                                                                                             |
| ------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| **nvim**     | `~/.config/nvim`                                       | Neovim 0.11+: blink.cmp, mini.nvim, treesitter, snacks, toggleterm; hot-reloads the Omarchy theme |
| **ghostty**  | `~/.config/ghostty/config`                             | Colors come from the active theme's `ghostty.conf`                                                |
| **hypr**     | `~/.config/hypr/*.lua`, `*.conf`                       | Omarchy Quattro Lua overrides; the monitor profile depends on the machine                         |
| **waybar**   | `~/.config/waybar`                                     | Custom window pill, workspace indicators, cliamp status                                           |
| **tmux**     | `~/.config/tmux/tmux.conf`                             | C-Space prefix, vi mode                                                                           |
| **zsh**      | `~/.zshrc`, `~/.zshenv`                                | Zinit, fzf-tab, syntax highlighting                                                               |
| **ohmyposh** | `~/.config/ohmyposh/star.omp.json`                     | Prompt theme `star`                                                                               |
| **themes**   | `~/.config/omarchy/themes/*`                           | Omarchy themes and the matching VS Code extension                                                 |
| **omarchy**  | `~/.config/omarchy/{hooks,extensions,shell.toml}`      | `theme-set` hook (tmux/nvim), Quattro menu look, wallpaper pool shared by every theme             |
| **pi**       | `~/.pi/agent/{AGENTS.md,settings.json,mcp.json,skills/*,extensions/*}`, `~/.claude/settings.json` | Pi instructions, packages, MCP servers, own skills, the `guard` extension; Claude Code settings with the claude.ai-synced plugins off; removes the old `~/.claude` links |
| **obsidian** | `~/.local/bin/obsidian-autocommit`, systemd user units | Timer that commits the text of the local vault `~/Documents/Obsidian` every 15 min                |
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
| `industrial`                             | Instrumental brutalism from SimPlant: neutral greys, red for errors, amber for progress. Spec in [`themes/industrial/DESIGN.md`](themes/industrial/DESIGN.md) |

Edit Token upstream and re-run `themes/sync-token.sh`; never edit the copies. `themes/make-preview.sh` regenerates each theme's `preview.png`.

## Obsidian vault

The vault is not in this repo: this repo is public and the notes are private. Only the versioning mechanism lives here. The vault's git repo is local, has no remote, and tracks only text (`.md`, `.canvas`, `.base`, `.excalidraw`, `.puml` and `.obsidian/`). [`obsidian/autocommit.sh`](obsidian/autocommit.sh) holds that list, because the `.gitignore` files of code projects nested in the vault override the root rules.

## Development

Gate every change before a commit:

| Command                                              | Checks                                             |
| ---------------------------------------------------- | -------------------------------------------------- |
| `installer/check.sh`                                 | Installer tests, clippy, cyclomatic complexity < 4 |
| `bash pi/extensions/guard/test-guard-bash.sh`        | Shell risk rules of the Pi guard                   |
| `node --test pi/extensions/*/*.test.ts`              | Pi `guard` votes (Node 24+)                        |
| `bash obsidian/test-autocommit.sh`                   | Vault autocommit on a temporary repo               |

## System

- **OS**: Arch Linux (Omarchy)
- **WM**: Hyprland (Wayland)
- **Terminal**: Ghostty
- **Shell**: Zsh + Zinit + oh-my-posh
- **Editor**: Neovim 0.11+
- **GPU**: NVIDIA GeForce RTX 2060 SUPER (desktop)

## Credits

Built on [Omarchy](https://omarchy.org). The Token Meridian themes come from [Token](https://github.com/ThorstenRhau/token) by ThorstenRhau.
