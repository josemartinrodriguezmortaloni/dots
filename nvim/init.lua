-- ============================================================================
-- init.lua  ·  Neovim 0.12+ minimalist config
-- Stack: Python · TypeScript · Rust · Lua
-- ----------------------------------------------------------------------------
-- Dependencias externas (instalar una vez):
--   pacman -S ripgrep fd git lua-language-server rust-analyzer
--   pip install basedpyright
--   npm i -g @vtsls/language-server
--
-- Primera ejecución:
--   nvim abrirá un prompt de vim.pack — presioná `A` para instalar todo.
-- ----------------------------------------------------------------------------
-- Prefijos de <leader>:
--   <leader>f = find        (fzf-lua)
--   <leader>g = git         (gitsigns)
--   <leader>l = LSP / format
--   <leader>b = buffer
--   <leader>s = split
--   <leader>p = pack
--   <leader>t = terminal    (nvterm)
--   <leader>e = explorer    (neo-tree)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. OPTIONS
-- ----------------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.o

-- UI
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false
o.termguicolors = true
o.showmode = false -- statusline ya muestra el modo
o.splitright = true
o.splitbelow = true
o.laststatus = 3 -- statusline global (una sola línea)
o.pumheight = 12
o.winborder = "rounded" -- bordes redondeados en flotantes
o.pumborder = "rounded" -- bordes en el menú de completado
o.list = true

-- Indent (overrides por filetype más abajo)
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.smartindent = true

-- Búsqueda
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true

-- Persistencia y performance
o.undofile = true
o.swapfile = false
o.updatetime = 250
o.timeoutlen = 400

-- Completado nativo (Neovim 0.12)
o.autocomplete = true
o.completeopt = "menu,menuone,noselect,popup,nearest"
o.shortmess = o.shortmess .. "c"

-- Clipboard del sistema
o.clipboard = "unnamedplus"

-- Colorscheme: poné el tuyo si tenés uno custom (ej: vitesse-light)
-- vim.cmd.colorscheme('habamax')

-- ----------------------------------------------------------------------------
-- 2. KEYMAPS BASE
-- ----------------------------------------------------------------------------

local map = vim.keymap.set

-- Guardar / salir
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Guardar" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Salir" })
map("n", "<leader>Q", "<cmd>qall!<CR>", { desc = "Salir forzado" })

-- Limpiar highlight de búsqueda con Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Quitar highlight" })

-- Navegación entre ventanas (h j k l como siempre)
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })

-- Splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>sc", "<C-w>c", { desc = "Cerrar split" })
map("n", "<leader>so", "<C-w>o", { desc = "Solo este split" })

-- Buffers
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Buffer siguiente" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Buffer anterior" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Cerrar buffer" })

-- Mover selección en visual
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })

-- Mantener cursor centrado al scrollear y buscar
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Preservar selección al indentar en visual
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Terminal: doble Esc para volver a modo normal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: modo normal" })

-- Pack manager
map("n", "<leader>pu", function()
	vim.pack.update()
end, { desc = "Pack: actualizar" })

-- ----------------------------------------------------------------------------
-- 3. AUTOCOMANDOS
-- ----------------------------------------------------------------------------

local function aug(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Highlight al copiar (yank)
vim.api.nvim_create_autocmd("TextYankPost", {
	group = aug("yank-highlight"),
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})

-- Trim trailing whitespace al guardar (excepto markdown/diff)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = aug("trim-whitespace"),
	callback = function()
		if vim.bo.filetype == "markdown" or vim.bo.filetype == "diff" then
			return
		end
		local view = vim.fn.winsaveview()
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})

-- Indentación de 2 espacios para web/config
vim.api.nvim_create_autocmd("FileType", {
	group = aug("web-indent"),
	pattern = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"json",
		"jsonc",
		"html",
		"css",
		"scss",
		"yaml",
		"lua",
		"toml",
	},
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.softtabstop = 2
	end,
})

-- ----------------------------------------------------------------------------
-- 4. PLUGINS (vim.pack — gestor nativo de 0.12)
-- ----------------------------------------------------------------------------

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" },
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-neo-tree/neo-tree.nvim",
	"https://github.com/NvChad/nvterm",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/mrcjkb/rustaceanvim",
	"https://github.com/ellisonleao/gruvbox.nvim",
})

-- ----------------------------------------------------------------------------
-- 5. SETUP DE PLUGINS
-- ----------------------------------------------------------------------------

-- mini.* (cherry-picking de módulos)
do
	local icons = require("mini.icons")
	icons.setup()
	icons.mock_nvim_web_devicons() -- para que fzf-lua / neo-tree obtengan iconos
end
require("mini.pairs").setup() -- auto cerrado de brackets/comillas
require("mini.surround").setup() -- sa / sd / sr
require("mini.ai").setup() -- text objects extendidos (vi( va{ etc.)
require("mini.statusline").setup() -- statusline minimalista

-- Treesitter (rama master, clásica y estable)
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"python",
		"typescript",
		"tsx",
		"javascript",
		"rust",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"json",
		"jsonc",
		"toml",
		"yaml",
		"markdown",
		"markdown_inline",
		"bash",
		"html",
		"css",
		"sql",
		"dockerfile",
		"regex",
	},
	auto_install = true,
	sync_install = false,
	ignore_install = {},
	modules = {},
	highlight = { enable = true },
	indent = { enable = true },
})

-- fzf-lua
require("fzf-lua").setup({ "default-title" })
-- Archivos
map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Buscar archivos" })
map("n", "<leader>fg", "<cmd>FzfLua git_files<CR>", { desc = "Archivos de git" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<CR>", { desc = "Recientes" })
-- Búsqueda de contenido
map("n", "<leader>fs", "<cmd>FzfLua live_grep<CR>", { desc = "Buscar texto" })
map("n", "<leader>fw", "<cmd>FzfLua grep_cword<CR>", { desc = "Palabra bajo cursor" })
-- Editor / ayuda
map("n", "<leader>fh", "<cmd>FzfLua helptags<CR>", { desc = "Ayuda" })
map("n", "<leader>fk", "<cmd>FzfLua keymaps<CR>", { desc = "Keymaps" })
map("n", "<leader>fc", "<cmd>FzfLua commands<CR>", { desc = "Comandos ex" })
map("n", "<leader>fx", "<cmd>FzfLua command_history<CR>", { desc = "Historial de comandos" })
map("n", "<leader>f/", "<cmd>FzfLua search_history<CR>", { desc = "Historial de búsquedas" })
map("n", "<leader>fm", "<cmd>FzfLua marks<CR>", { desc = "Marcas" })
map("n", "<leader>fR", "<cmd>FzfLua registers<CR>", { desc = "Registers" })
-- Diagnósticos / LSP / listas
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", { desc = "Diagnósticos (buffer)" })
map("n", "<leader>fD", "<cmd>FzfLua diagnostics_workspace<CR>", { desc = "Diagnósticos (workspace)" })
map("n", "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", { desc = "Símbolos (workspace)" })
map("n", "<leader>fq", "<cmd>FzfLua quickfix<CR>", { desc = "Quickfix" })
-- Reabrir último picker (con query)
map("n", "<leader>f.", "<cmd>FzfLua resume<CR>", { desc = "Reabrir último picker" })

-- neo-tree (file explorer)
require("neo-tree").setup({
	close_if_last_window = true,
	popup_border_style = "rounded",
	enable_git_status = true,
	enable_diagnostics = true,
	filesystem = {
		follow_current_file = { enabled = true },
		use_libuv_file_watcher = true,
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
			hide_gitignored = false,
		},
	},
	window = {
		width = 32,
		mappings = { ["<space>"] = "none" },
	},
	default_component_configs = {
		indent = { with_markers = true, with_expanders = true },
	},
})
map("n", "-", "<cmd>Neotree toggle<CR>", { desc = "Explorador (toggle)" })
map("n", "<leader>e", "<cmd>Neotree toggle reveal<CR>", { desc = "Explorador de archivos" })
map("n", "<leader>E", "<cmd>Neotree focus<CR>", { desc = "Focus explorador" })

-- gitsigns.nvim
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local kopt = function(desc)
			return { buffer = bufnr, desc = desc }
		end

		map("n", "]c", function()
			gs.nav_hunk("next")
		end, kopt("Git: hunk siguiente"))
		map("n", "[c", function()
			gs.nav_hunk("prev")
		end, kopt("Git: hunk anterior"))

		map("n", "<leader>gs", gs.stage_hunk, kopt("Git: stage hunk"))
		map("n", "<leader>gr", gs.reset_hunk, kopt("Git: reset hunk"))
		map("n", "<leader>gS", gs.stage_buffer, kopt("Git: stage buffer"))
		map("n", "<leader>gp", gs.preview_hunk, kopt("Git: preview hunk"))
		map("n", "<leader>gb", function()
			gs.blame_line({ full = true })
		end, kopt("Git: blame línea"))
		map("n", "<leader>gd", gs.diffthis, kopt("Git: diff"))
	end,
})

-- rustaceanvim: NO configurar rust-analyzer en vim.lsp.config, lo maneja este plugin
vim.g.rustaceanvim = {
	server = {
		default_settings = {
			["rust-analyzer"] = {
				check = { command = "clippy" },
				cargo = { allFeatures = true },
			},
		},
	},
}

-- nvterm (terminales integradas)
require("nvterm").setup({
	terminals = {
		type_opts = {
			float = {
				relative = "editor",
				row = 0.15,
				col = 0.15,
				width = 0.7,
				height = 0.7,
				border = "rounded",
			},
			horizontal = { location = "rightbelow", split_ratio = 0.3 },
			vertical = { location = "rightbelow", split_ratio = 0.5 },
		},
	},
})
do
	local term = require("nvterm.terminal")
	map({ "n", "t" }, "<A-i>", function()
		term.toggle("float")
	end, { desc = "Terminal flotante" })
	map({ "n", "t" }, "<A-h>", function()
		term.toggle("horizontal")
	end, { desc = "Terminal horizontal" })
	map({ "n", "t" }, "<A-v>", function()
		term.toggle("vertical")
	end, { desc = "Terminal vertical" })
	map("n", "<leader>tf", function()
		term.toggle("float")
	end, { desc = "Terminal flotante" })
	map("n", "<leader>th", function()
		term.toggle("horizontal")
	end, { desc = "Terminal horizontal" })
	map("n", "<leader>tv", function()
		term.toggle("vertical")
	end, { desc = "Terminal vertical" })
	map("n", "<leader>tn", function()
		term.new("horizontal")
	end, { desc = "Nueva terminal" })
end

-- conform.nvim (formateo multi-lenguaje)
require("conform").setup({
	formatters_by_ft = {
		python = { "ruff_format", "ruff_organize_imports" },
		lua = { "stylua" },
		rust = { "rustfmt" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		html = { "prettier" },
		markdown = { "prettier" },
		yaml = { "prettier" },
	},
	default_format_opts = { lsp_format = "fallback", timeout_ms = 1500 },
})

-- Autoformat al salir del modo insert
vim.api.nvim_create_autocmd("InsertLeave", {
	group = aug("autoformat-insert-leave"),
	callback = function()
		if vim.b.disable_autoformat or vim.g.disable_autoformat then
			return
		end
		require("conform").format({ async = true, lsp_format = "fallback" })
	end,
})

-- Autoformat después de pegar (respeta register y count)
local function paste_then_format(key)
	return function()
		local reg = vim.v.register
		local count = vim.v.count1
		vim.cmd(('normal! "%s%d%s'):format(reg, count, key))
		if vim.b.disable_autoformat or vim.g.disable_autoformat then
			return
		end
		vim.schedule(function()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end)
	end
end
map("n", "p", paste_then_format("p"), { desc = "Pegar + formatear" })
map("n", "P", paste_then_format("P"), { desc = "Pegar encima + formatear" })

-- Format manual (<leader>lF) y toggle de autoformat por buffer (<leader>lT)
map("n", "<leader>lF", function()
	require("conform").format({ async = true })
end, { desc = "Formatear (conform)" })
map("n", "<leader>lT", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	vim.notify("Autoformat " .. (vim.b.disable_autoformat and "OFF" or "ON") .. " (buffer)")
end, { desc = "Toggle autoformat (buffer)" })

-- ----------------------------------------------------------------------------
-- 6. LSP (API nativa 0.12)
-- ----------------------------------------------------------------------------

vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
			},
		},
	},
})

vim.lsp.config("vtsls", {
	cmd = { "vtsls", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.enable({ "basedpyright", "vtsls", "lua_ls" })

-- Al conectarse un servidor: habilitar autocompletado nativo + mapear acciones
vim.api.nvim_create_autocmd("LspAttach", {
	group = aug("lsp-attach"),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end
		local b = ev.buf
		local kopt = function(desc)
			return { buffer = b, desc = desc }
		end

		-- Autocompletado nativo (0.12)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, b, { autotrigger = true })
		end

		-- Navegación (g = go to)
		map("n", "gd", vim.lsp.buf.definition, kopt("LSP: definición"))
		map("n", "gi", vim.lsp.buf.implementation, kopt("LSP: implementación"))
		map("n", "gr", vim.lsp.buf.references, kopt("LSP: referencias"))
		map("n", "K", vim.lsp.buf.hover, kopt("LSP: hover"))

		-- Acciones (l = lsp)
		map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, kopt("LSP: code action"))
		map("n", "<leader>lr", vim.lsp.buf.rename, kopt("LSP: rename"))
		map("n", "<leader>lf", function()
			vim.lsp.buf.format({ async = true })
		end, kopt("LSP: format"))
		map("n", "<leader>ls", vim.lsp.buf.document_symbol, kopt("LSP: símbolos"))
		map("n", "<leader>lt", vim.lsp.buf.type_definition, kopt("LSP: type def"))
		map("n", "<leader>lD", vim.lsp.buf.declaration, kopt("LSP: declaración"))
	end,
})

-- <CR> confirma selección del popup si hay una, si no hace newline normal
map("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		local info = vim.fn.complete_info({ "selected" })
		return info.selected ~= -1 and "<C-y>" or "<C-e><CR>"
	end
	return "<CR>"
end, { expr = true, desc = "Confirmar completado o nueva línea" })

-- Tab / Shift-Tab navegan el popup de completado
map("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
map("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

-- ----------------------------------------------------------------------------
-- 7. DIAGNÓSTICOS
-- ----------------------------------------------------------------------------

vim.diagnostic.config({
	virtual_text = { spacing = 4, prefix = "●" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = true },
})

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Diag: siguiente" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Diag: anterior" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Diag: línea actual" })
map("n", "<leader>ll", vim.diagnostic.setloclist, { desc = "Diag: loclist" })

-- ----------------------------------------------------------------------------
-- 8. COLORSCHEME
-- ----------------------------------------------------------------------------

require("gruvbox").setup({
	terminal_colors = true, -- add neovim terminal colors
	undercurl = true,
	underline = true,
	bold = true,
	italic = {
		strings = true,
		emphasis = true,
		comments = true,
		operators = false,
		folds = true,
	},
	strikethrough = true,
	invert_selection = false,
	invert_signs = false,
	invert_tabline = false,
	inverse = true, -- invert background for search, diffs, statuslines and errors
	contrast = "", -- can be "hard", "soft" or empty string
	palette_overrides = {},
	overrides = {},
	dim_inactive = false,
	transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")
