# plain entra como un par de Temas de Omarchy

El Colorscheme `plain` (port de ahmedelgabri/dotfiles@c12ff76) se registra como dos Temas de Omarchy, `plain-dark` y `plain-light`, en lugar de reemplazar el hot-reload de Omarchy dentro de Neovim. Así nvim sigue el selector de Temas del escritorio. Un Tema de Omarchy tiene un solo `mode`, por eso cada Modo es un Tema distinto. El `colors.toml` de cada Tema es el de `token-meridian` o el de `token-meridian-light`, así que el resto del escritorio no cambia: solo cambia el Colorscheme.

El Modo de Neovim sale del `mode` del `colors.toml` del Tema activo (`nvim/lua/omarchy/mode.lua`). Ese valor se fija al arrancar y en cada hot-reload. Antes el hot-reload forzaba `background = "dark"`, y cada Tema claro tenía que corregirlo por su cuenta.

## Considered Options

- Reemplazar Omarchy por `plain` dentro de nvim: se descartó porque rompe la coherencia con el selector de Temas del escritorio.
- Adoptar solo la estructura de highlights de plain sobre la paleta de Omarchy: se descartó porque pierde el rasgo central del Estilo, que es la sintaxis casi monocroma.

## Consequences

- Los archivos de terminal de `plain-*` (`ghostty.conf`, `kitty.conf`, `pi.json`, `obsidian.css`) son copias de `token-meridian*`. `themes/sync-token.sh` no los actualiza, así que hay que re-copiarlos cuando se actualiza Token.
