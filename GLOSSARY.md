# Dots

Configuración personal del escritorio Omarchy y de sus herramientas (Neovim, terminal, barra, shell), versionada para reproducirla en cualquier máquina.

## Language

### Apariencia

**Estilo**:
La apariencia de una herramienta más el comportamiento de su interfaz (bordes, columnas, mensajes, folds); excluye keymaps, plugins de flujo de trabajo y LSP.
_Avoid_: Look, config, setup

**Tema**:
Unidad de apariencia de Omarchy que fija la paleta de todo el escritorio a la vez; tiene exactamente un Modo.
_Avoid_: Theme de nvim, skin

**Modo**:
La luminosidad de un Tema: claro u oscuro. Un mismo diseño con ambos Modos son dos Temas distintos (por ejemplo `token-meridian` y `token-meridian-light`).
_Avoid_: Variante, background, appearance

**Colorscheme**:
La parte de un Tema que aplica la paleta dentro de Neovim.
_Avoid_: Tema (cuando se habla solo de Neovim)

### Adopción de configuración ajena

**Port adaptado**:
Copia de un Estilo ajeno que reproduce su resultado visual sobre la base propia (LazyVim y los plugins ya instalados), fijada a un commit de origen.
_Avoid_: Copia literal, fork, sync
