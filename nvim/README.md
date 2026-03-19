# Neovim Minimal Configuration

> **Una configuración de Neovim minimalista, potente y sin bloat** \
> Sin frameworks pesados como LazyVim. Solo lo esencial.

---

## 🎯 Objetivo

Esta configuración fue diseñada con una filosofia clara: **menos es más**. El objetivo es proporcionar un entorno de desarrollo productivo, rápido y elegante sin la complejidad innecesaria de distribuciones preconfiguradas. Cada plugin y cada keymap tienen un propósito específico y justificado.

**Principios de diseño:**
- ✅ **Minimalismo**: Solo herramientas esenciales, sin redundancias
- ✅ **Velocidad**: Startup rápido, optimizado para rendimiento
- ✅ **Productividad**: Keymaps ergonómicos y workflows eficientes
- ✅ **Mantenibilidad**: Configuración limpia, bien documentada y fácil de entender
- ✅ **No bloat**: Sin dependencias innecesarias ni funciones que nunca usarás

---

## 🚀 Beneficios

### 1. **Startup Instantáneo**
Al no usar distribuciones pesadas, el tiempo de carga es mínimo. La configuración carga solo lo necesario, permitiéndote comenzar a trabajar en milisegundos en lugar de segundos.

### 2. **Comprensión Total**
Con configuraciones como LazyVim, hay miles de líneas de código que no entiendes. Aquí, cada línea de tu `init.lua` es tuya. Si algo no funciona, sabes exactamente dónde buscar y cómo arreglarlo.

### 3. **Personalización Exacta**
No necesitas lidiar con configuraciones preexistentes que no te gustan. Cada keymap, cada plugin y cada ajuste fue seleccionado intencionalmente. Si quieres cambiar algo, es trivial.

### 4. **Menos Dependencias**
Al eliminar plugins redundantes, reduces el riesgo de conflictos, bugs y problemas de mantenimiento. Menos plugins = menos cosas que pueden romperse.

### 5. **Flujos de Trabajo Optimizados**
Los keymaps están diseñados pensando en la ergonomía:
- `<Space>` como leader key (fácil de alcanzar)
- Navegación de ventanas con `Ctrl+h/j/k/l` (como vim-tmux-navigator)
- Movimiento de líneas con `Alt+j/k` (sin salir de modo visual)
- Terminal integrada accesible con `Alt+h/i/v`

### 6. **Soporte Multi-Lenguaje Robusto**
Gracias a LSP (Language Server Protocol), tienes:
- Autocompletado inteligente
- Ir a definición (`gd`)
- Referencias (`gr`)
- Renombrado (`<leader>rn`)
- Acciones de código (`<leader>ca`)
- Diagnósticos en tiempo real

### 7. **Git Integrado**
LazyGit integrado directamente (`<leader>lg`) para gestión de git visual sin salir del editor.

---

## 📦 Stack de Plugins

### **Core**
- **[lazy.nvim](https://github.com/folke/lazy.nvim)**: Plugin manager moderno y rápido
- **[nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)**: Iconos de archivos

### **Tema y UI**
- **[catppuccin/nvim](https://github.com/catppuccin/nvim)**: Tema "Latte" (light theme) con integraciones
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)**: Statusline minimalista y transparente
- **[dashboard-nvim](https://github.com/nvimdev/dashboard-nvim)**: Pantalla de inicio estilo Doom

### **Fuzzy Finder**
- **[fzf-lua](https://github.com/ibhagwan/fzf-lua)**: Buscador rápido para archivos, buffers, grep, etc.

### **Syntax & Code Intelligence**
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: Highlighting y parsing avanzado
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)**: Configuración LSP (Neovim 0.11+ API nativa)
- **[mason.nvim](https://github.com/williamboman/mason.nvim)**: Gestor de LSPs, formatters y linters

### **Formatters & Linters**
- **[conform.nvim](https://github.com/stevearc/conform.nvim)**: Formateo automático on-save
- **[nvim-lint](https://github.com/mfussenegger/nvim-lint)**: Linting en tiempo real

### **Utilities**
- **[nvterm](https://github.com/NvChad/nvterm)**: Terminal integrado (float, horizontal, vertical)
- **[mini.files](https://github.com/echasnovski/mini.files)**: Explorador de archivos con preview
- **[lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)**: Interfaz para LazyGit
- **[markview.nvim](https://github.com/OXY2DEV/markview.nvim)**: Preview mejorado de Markdown

---

## ⌨️ Keymaps Principales

### **General**
| Keymap | Acción |
|--------|--------|
| `jk` / `ii` | Salir de insert mode |
| `<leader>ww` | Guardar archivo |
| `<leader>wq` | Guardar y salir |
| `<leader>qq` | Salir sin guardar |
| `<C-s>` | Guardar archivo (custom con notificación) |
| `<C-A>` | Seleccionar todo |
| `gx` | Abrir URL bajo cursor |

### **Window Management**
| Keymap | Acción |
|--------|--------|
| `<leader>sv` | Split vertical |
| `<leader>sh` | Split horizontal |
| `<leader>se` | Equalizar splits |
| `<C-h/j/k/l>` | Navegar entre ventanas |
| `<C-S-h/j/k/l>` | Redimensionar ventanas |
| `<leader>sx` | Cerrar split |

### **Move Lines**
| Keymap | Acción |
|--------|--------|
| `<A-j>` / `<A-k>` | Mover línea/ selección abajo/arriba (Normal, Insert, Visual) |

### **Buffers & Tabs**
| Keymap | Acción |
|--------|--------|
| `<S-h>` / `<S-l>` | Buffer anterior/siguiente |
| `[b` / `]b` | Buffer anterior/siguiente |
| `<leader>bd` | Borrar buffer |
| `<leader>bb` | Buffer alternativo |
| `<leader>to` | Nueva tab |
| `<leader>tx` | Cerrar tab |

### **Fuzzy Finder (fzf-lua)**
| Keymap | Acción |
|--------|--------|
| `<leader>ff` / `<Space><Space>` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` / `<leader>,` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fh` | Help tags |
| `<leader>fc` | Config files (en stdpath) |

### **Terminal (nvterm)**
| Keymap | Acción |
|--------|--------|
| `<A-i>` | Toggle float terminal |
| `<A-h>` / `<leader>th` | Toggle horizontal terminal |
| `<A-v>` / `<leader>tv` | Toggle vertical terminal |

### **LSP**
| Keymap | Acción |
|--------|--------|
| `gd` | Ir a definición |
| `gD` | Ir a declaración |
| `gr` | Referencias |
| `gi` | Implementación |
| `K` | Hover documentation |
| `<leader>rn` | Renombrar símbolo |
| `<leader>ca` | Code actions |
| `<leader>gl` | Diagnósticos (float) |
| `[d` / `]d` | Ir a diagnóstico previo/siguiente |
| `<leader>cf` | Formatear buffer |

### **Git**
| Keymap | Acción |
|--------|--------|
| `<leader>lg` | Abrir LazyGit |

### **Mini Files**
| Keymap | Acción |
|--------|--------|
| `<leader>fm` | Abrir mini.files (directorio del archivo actual) |
| `<leader>fM` | Abrir mini.files (cwd) |

---

## 🔧 Configuraciones Clave

### **Neovim Options**
- **Números de línea**: Relativos + absolutos (para movimientos rápidos)
- **Indentación**: 2 espacios por defecto, expandtab
- **Búsqueda**: ignorecase + smartcase
- **Cursorline**: Siempre visible
- **Clipboard**: unnamedplus (compartir con sistema)
- **Mouse**: habilitado para todas las acciones
- **Fold**: Treesitter-based folding

### **LSP Servers Configurados**
- `lua_ls`: Lua con diagnósticos para globals `{ "vim" }`
- `pyright`: Python (type checking)
- `ruff`: Python (linting rápido)
- `ts_ls`: TypeScript/JavaScript

### **Formatters (conform.nvim)**
| Lenguaje | Formatters |
|----------|------------|
| Lua | `stylua` |
| Python | `ruff_format`, `ruff_fix` |
| JavaScript/TypeScript | `prettier` |
| JSON/YAML/Markdown | `prettier` |
| Shell | `shfmt` |

### **Linters (nvim-lint)**
| Lenguaje | Linter |
|----------|--------|
| Python | `ruff` |
| JavaScript/TypeScript | `eslint` |
| Shell | `shellcheck` |

### **Terminal (nvterm)**
- Shell: PowerShell (`pwsh`)
- Float terminal con borde single
- Terminal horizontal (30% height)
- Terminal vertical (50% width)
- Auto-insert al abrir terminal
- Auto-close al salir

---

## 🎨 Personalización

### **Cambiar el Tema**
Para cambiar de "Latte" (light) a "Mocha" (dark):

```lua
-- Busca la configuración de catppuccin en init.lua
opts = {
  flavour = "mocha",  -- Cambia de "latte" a "mocha"
  -- ...
}
```

O cambia el fondo en las options:

```lua
opt.background = "dark"  -- Cambia de "light" a "dark"
```

### **Añadir un Nuevo LSP Server**
1. Instalar el servidor con Mason (`:Mason`)
2. Añadir a `ensure_installed` en mason-lspconfig
3. Configurar en nvim-lspconfig:

```lua
vim.lsp.config("nuevo_lsp", {})
vim.lsp.enable({ "nuevo_lsp" })
```

### **Añadir un Nuevo Formatter**
Añadir a `formatters_by_ft` en conform.nvim:

```lua
formatters_by_ft = {
  tu_lenguaje = { "formatter" },
  -- ...
}
```

### **Cambiar la Terminal Shell**
Si prefieres bash, zsh, fish u otro shell:

```lua
terminals = {
  shell = "bash",  -- Cambia de "pwsh"
  -- ...
}
```

---

## 🛠️ Requisitos Previos

### **Obligatorios**
- Neovim 0.11+ (para LSP config nativa)
- Git (para clonar plugins)
- Node.js & npm (para algunos LSPs/formatters)

### **Recomendados**
- [LazyGit](https://github.com/jesseduffield/lazygit): Para integración git
- [ripgrep](https://github.com/BurntSushi/ripgrep): Para búsqueda rápida
- [fd](https://github.com/sharkdp/fd): Para búsqueda de archivos
- [bat](https://github.com/sharkdp/bat): Para preview en fzf-lua

### **LSP Servers**
Los siguientes se instalan automáticamente vía Mason:
- `lua-language-server`
- `pyright`
- `ruff`
- `typescript-language-server`

### **Formatters**
Instala manualmente según tu lenguaje:
```bash
# Lua
pip install stylua

# Python
pip install ruff

# JavaScript/TypeScript
npm install -g prettier

# Shell
# shellcheck (disponible en most package managers)
```

---

## 📚 Estructura del Archivo

```lua
-- ════════════════════════════════════════════════════════════════════════════
-- OPTIONS          (líneas 9-69): Configuraciones de Neovim
-- ════════════════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════════════════
-- KEYMAPS          (líneas 72-202): Mapeos de teclas
-- ════════════════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════════════════
-- LAZY.NVIM        (líneas 204-220): Bootstrap del plugin manager
-- ════════════════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════════════════
-- PLUGINS          (líneas 222-740): Configuración de plugins
-- ════════════════════════════════════════════════════════════════════════════
```

---

## 🚀 Comandos Útiles

```vim
" Abrir Mason (gestor de LSPs/formatters)
:Mason

" Ver plugins instalados
:Lazy

" Actualizar plugins
:Lazy update

" Limpiar plugins no utilizados
:Lazy clean

" Ver información de formatters
:ConformInfo

" Ver diagnósticos LSP
:LspInfo

" Abrir LazyGit
:LazyGit

" Recargar configuración
:source %   (en init.lua)
```

---

## 🎓 Filosofía vs LazyVim/NvChad

| Aspecto | Esta Configuración | LazyVim/NvChad |
|---------|-------------------|----------------|
| **Líneas de código** | ~740 (todo en un archivo) | 10,000+ (múltiples módulos) |
| **Plugins** | ~20 (esenciales) | 50+ (con redundancias) |
| **Startup time** | <100ms | 200-500ms |
| **Customización** | Editar directamente | Aprender estructura compleja |
| **Entendimiento** | Control total | Caja negra |
| **Bloat** | Ninguno | Considerable |

**¿Cuándo elegir esta configuración?**
- ✅ Quieres entender tu entorno de trabajo
- ✅ Valoras la velocidad sobre la cantidad de características
- ✅ Prefieres configuración simple sobre arquitectura compleja
- ✅ Te gusta tener control total

**¿Cuándo elegir LazyVim/NvChad?**
- ❌ Quieres configuración zero-setup
- ❌ Necesitas miles de plugins preconfigurados
- ❌ No te importa la complejidad interna

---

## 🤝 Contribuciones

Esta es una configuración personal, pero si encuentras algo útil, ¡siéntete libre de copiar y adaptar a tus necesidades!

## 📄 Licencia

MIT - Haz lo que quieras con ella.

---

**Hecho con 💻 y ☕ por alguien que odia el bloat.**
