# Doom Emacs config — INACTIVE BACKUP

Kept for reference only. **Nothing here is applied.**

Emacs now runs [N Λ N O](https://github.com/rougier/nano-emacs); the live config
is `../nano/`.

## Why it is inert

`doom` was removed from `MODULE_KEYS` in `../install.sh`, so `./install.sh` no
longer links these files into `~/.config/doom/`. The Doom framework itself
(`~/.emacs.d/`) was deleted during the migration.

## Gotcha worth remembering

Emacs 27+ prefers `~/.emacs.d/` over `~/.config/emacs/` **when both exist**.
While the Doom install was still present it kept winning startup, and the nano
config at `~/.config/emacs/init.el` was never read — even though the symlink
was in place. If you ever restore Doom, that precedence is what to check first.

## Restoring it

1. Reinstall the framework: `git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d`
2. Link these three files into `~/.config/doom/`
3. `~/.emacs.d/bin/doom sync`

Note that step 1 puts `~/.emacs.d` back, which will shadow the nano config.
