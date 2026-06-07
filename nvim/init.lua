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
o.showmode = false
o.splitright = true
o.splitbelow = true
o.laststatus = 3
o.pumheight = 12
o.winborder = "rounded"
o.pumborder = "rounded"
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

-- ----------------------------------------------------------------------------
-- 2. KEYMAPS BASE
-- ----------------------------------------------------------------------------

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Guardar" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Salir" })
map("n", "<leader>Q", "<cmd>qall!<CR>", { desc = "Salir forzado" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Quitar highlight" })

-- Ventanas
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>sc", "<C-w>c", { desc = "Cerrar split" })
map("n", "<leader>so", "<C-w>o", { desc = "Solo este split" })

-- Buffers
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Buffer siguiente" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Buffer anterior" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Cerrar buffer" })

-- Visual
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Scroll y búsqueda centrada
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Terminal
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
		vim.bo.tabstop, vim.bo.shiftwidth, vim.bo.softtabstop = 2, 2, 2
	end,
})

-- ----------------------------------------------------------------------------
-- 4. PLUGINS (vim.pack — gestor nativo de 0.12)
-- ----------------------------------------------------------------------------

vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/NvChad/nvterm",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/OXY2DEV/markview.nvim",
	"https://github.com/sindrets/diffview.nvim.git",
})
-- El plugin del colorscheme NO se declara acá: lo instala de forma perezosa la
-- integración con Omarchy (sección 8), solo el del tema activo.

-- ----------------------------------------------------------------------------
-- 5. SETUP DE PLUGINS
-- ----------------------------------------------------------------------------

-- mini.* (cherry-picking)
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.ai").setup()
require("mini.statusline").setup()
require("mini.diff").setup()
map("n", "<leader>go", function()
	require("mini.diff").toggle_overlay(0)
end, { desc = "Git: toggle overlay" })

-- Treesitter (rama main)
require("nvim-treesitter").install({
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
})
vim.treesitter.language.register("json", "jsonc")

vim.api.nvim_create_autocmd("FileType", {
	group = aug("treesitter-start"),
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- fzf-lua
require("fzf-lua").setup({ "default-title" })
for _, m in ipairs({
	{ "ff", "files", "Archivos" },
	{ "fg", "git_files", "Archivos git" },
	{ "fb", "buffers", "Buffers" },
	{ "fr", "oldfiles", "Recientes" },
	{ "fs", "live_grep", "Buscar texto" },
	{ "fw", "grep_cword", "Palabra bajo cursor" },
	{ "fc", "commands", "Comandos" },
	{ "fk", "keymaps", "Keymaps" },
	{ "fh", "helptags", "Ayuda" },
	{ "fd", "diagnostics_document", "Diag (buffer)" },
	{ "fD", "diagnostics_workspace", "Diag (workspace)" },
	{ "fS", "lsp_live_workspace_symbols", "Símbolos" },
	{ "f.", "resume", "Reabrir picker" },
}) do
	map("n", "<leader>" .. m[1], "<cmd>FzfLua " .. m[2] .. "<CR>", { desc = m[3] })
end

-- nvterm
require("nvterm").setup({
	terminals = {
		type_opts = {
			float = { relative = "editor", row = 0.15, col = 0.15, width = 0.7, height = 0.7, border = "rounded" },
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
	map("n", "<leader>tn", function()
		term.new("horizontal")
	end, { desc = "Nueva terminal" })
end

-- conform.nvim
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

vim.api.nvim_create_autocmd("InsertLeave", {
	group = aug("autoformat-insert-leave"),
	callback = function()
		if vim.b.disable_autoformat or vim.g.disable_autoformat then
			return
		end
		require("conform").format({ async = true, lsp_format = "fallback" })
	end,
})

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

map("n", "<leader>lF", function()
	require("conform").format({ async = true })
end, { desc = "Formatear" })
map("n", "<leader>lT", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	vim.notify("Autoformat " .. (vim.b.disable_autoformat and "OFF" or "ON") .. " (buffer)")
end, { desc = "Toggle autoformat (buffer)" })

-- ----------------------------------------------------------------------------
-- 6. LSP (API nativa 0.12)
-- ----------------------------------------------------------------------------

local servers = {
	basedpyright = {
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
	},
	vtsls = {
		cmd = { "vtsls", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
		settings = {
			typescript = {
				referencesCodeLens = { enabled = true, showOnAllFunctions = true },
				implementationsCodeLens = { enabled = true },
			},
			javascript = {
				referencesCodeLens = { enabled = true, showOnAllFunctions = true },
				implementationsCodeLens = { enabled = true },
			},
		},
	},
	clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--function-arg-placeholders",
		},
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
		root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", "Makefile", ".git" },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME .. "/lua",
						"${3rd}/luv/library",
					},
				},
				diagnostics = { globals = { "vim" } },
				telemetry = { enable = false },
			},
		},
	},
	rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", ".git" },
		settings = {
			["rust-analyzer"] = {
				check = { command = "clippy" },
				cargo = { allFeatures = true },
				lens = {
					enable = true,
					run = { enable = true },
					debug = { enable = true },
					implementations = { enable = false },
					references = {
						adt = { enable = false },
						method = { enable = false },
						trait = { enable = false },
						enumVariant = { enable = false },
					},
				},
			},
		},
	},
}

for name, cfg in pairs(servers) do
	vim.lsp.config(name, cfg)
end
vim.lsp.enable(vim.tbl_keys(servers))

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

		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, b, { autotrigger = true })
		end

		if client:supports_method("textDocument/linkedEditingRange") then
			vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
		end

		if client:supports_method("textDocument/codeLens") then
			local g = vim.api.nvim_create_augroup("lsp-codelens-" .. b, { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
				group = g,
				buffer = b,
				callback = function()
					vim.lsp.codelens.refresh({ bufnr = b })
				end,
			})
			vim.lsp.codelens.refresh({ bufnr = b })
		end

		-- Defaults 0.12 ya provistos: gd, K, grn, gra, grr, gri, grt, grx, <C-s>
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

-- Popup de completado: <CR> confirma, Tab/S-Tab navegan
map("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		local info = vim.fn.complete_info({ "selected" })
		return info.selected ~= -1 and "<C-y>" or "<C-e><CR>"
	end
	return "<CR>"
end, { expr = true, desc = "Confirmar completado o nueva línea" })
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

require("diffview").setup()
require("markview").setup()

-- ----------------------------------------------------------------------------
-- 8. INTEGRACIÓN CON EL TEMA DE OMARCHY
-- ----------------------------------------------------------------------------
-- Neovim sigue el tema activo de Omarchy. Cada tema expone en
-- ~/.config/omarchy/current/theme/neovim.lua un spec estilo LazyVim con el
-- plugin del colorscheme. Lo cargamos tal cual: instalamos ese plugin con
-- vim.pack (solo el del tema en uso), respetamos el branch/tag que fije y
-- ejecutamos su config() si lo trae (ahí viven los colores personalizados de
-- temas como greek-noir, ristretto o solarized). El hook
-- ~/.config/omarchy/hooks/theme-set invoca OmarchyReloadTheme() por RPC en las
-- instancias vivas.

local omarchy = {
	dir = vim.env.HOME .. "/.config/omarchy/current/theme",
	plug_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt",
	fallback = "default", -- colorscheme de respaldo si algo falla
}

-- Carga el neovim.lua del tema y separa el spec del plugin del colorscheme del
-- spec de LazyVim (del que solo nos interesa el nombre del colorscheme).
-- Soporta los dos formatos que usa Omarchy:
--   lista: { { "owner/repo", opts=…, config=… }, { "LazyVim/LazyVim", opts={colorscheme=…} } }
--   plano: { "owner/repo", opts=…, config=… }
local function omarchy_theme()
	local chunk = loadfile(omarchy.dir .. "/neovim.lua")
	if not chunk then
		return nil
	end
	local ok, spec = pcall(chunk)
	if not ok or type(spec) ~= "table" then
		return nil
	end

	local entries = type(spec[1]) == "string" and { spec } or spec
	local plugin, colorscheme
	for _, e in ipairs(entries) do
		if type(e) == "table" and type(e[1]) == "string" then
			if e[1] == "LazyVim/LazyVim" then
				colorscheme = (type(e.opts) == "table" and e.opts.colorscheme) or colorscheme
			else
				plugin = e -- spec del colorscheme
			end
		end
	end
	return plugin and { plugin = plugin, colorscheme = colorscheme } or nil
end

-- Aplica un colorscheme tolerando el alias de LazyVim (p. ej. el colorscheme
-- real de "catppuccin-nvim" es "catppuccin").
local function apply_colorscheme(name)
	if type(name) ~= "string" or name == "" then
		return false
	end
	for _, c in ipairs({ name, (name:gsub("%-nvim$", "")) }) do
		if pcall(vim.cmd.colorscheme, c) then
			return true
		end
	end
	return false
end

-- Descarta del cache de require el módulo del tema y sus submódulos, para que el
-- require de abajo lea la revisión recién puesta en disco. Necesario al recargar
-- en caliente entre temas que comparten plugin base en ramas distintas (p. ej.
-- aether v2 en greek-noir vs v3 en cpunk).
local function unload_module(name)
	for mod in pairs(package.loaded) do
		if mod == name or mod:sub(1, #name + 1) == name .. "." then
			package.loaded[mod] = nil
		end
	end
end

-- vim.pack.add no reajusta la revisión de un plugin ya presente en disco. Lo
-- llevamos a la que pide el tema (branch/tag/commit o, si no fija ninguna, la
-- rama por defecto del repo) y SOLO si de verdad difiere —así no hace ruido en
-- cada arranque—. Hacemos el checkout nosotros (no vim.pack.update) porque, en
-- una instancia viva, su estado en memoria impide cambiar de rama de forma
-- fiable. Hace falta al alternar temas que comparten plugin base en ramas
-- distintas (p. ej. aether v2 en greek-noir vs la default en cpunk).
local function sync_revision(name, ref)
	local path = omarchy.plug_dir .. "/" .. name
	local function git(...)
		return vim.system({ "git", "-C", path, ... }):wait()
	end
	local function rev(r)
		local out = git("rev-parse", "--verify", "--quiet", r .. "^{commit}")
		return out.code == 0 and vim.trim(out.stdout) or nil
	end
	if not ref then
		local def = git("rev-parse", "--abbrev-ref", "origin/HEAD")
		ref = def.code == 0 and vim.trim(def.stdout) or nil -- p. ej. "origin/v3"
	end
	local want = ref and (rev(ref) or rev("origin/" .. ref))
	if want and rev("HEAD") ~= want then
		git("checkout", "--quiet", want)
	end
end

-- Instala (si falta) y carga un plugin a partir de su spec, que puede ser un
-- string "owner/repo" o una tabla { "owner/repo", name=…, branch=… }. Devuelve
-- el nombre con que quedó en disco. `force_default` decide qué hacer cuando el
-- spec no fija revisión: el plugin principal va a la rama por defecto del repo,
-- pero una dependencia respeta la que ya esté instalada (suelen no fijar branch
-- y comparten plugin con otros temas; p. ej. aether en v2 para greek-noir).
local function add_plugin(spec, force_default)
	local repo = type(spec) == "string" and spec or (type(spec) == "table" and spec[1])
	if type(repo) ~= "string" then
		return nil
	end
	local opts = type(spec) == "table" and spec or {}
	local name = opts.name or repo:match("([^/]+)$")
	local ref = opts.version or opts.branch or opts.tag or opts.commit
	local existed = vim.uv.fs_stat(omarchy.plug_dir .. "/" .. name) ~= nil
	pcall(vim.pack.add, { { src = "https://github.com/" .. repo, name = name, version = ref } })
	if existed and (ref or force_default) then
		sync_revision(name, ref)
	end
	return name
end

function _G.OmarchyReloadTheme()
	-- Fondo claro/oscuro según el marcador light.mode del tema.
	vim.o.background = vim.uv.fs_stat(omarchy.dir .. "/light.mode") and "light" or "dark"

	local theme = omarchy_theme()
	if not theme then
		pcall(vim.cmd.colorscheme, omarchy.fallback)
		return ""
	end

	local plugin = theme.plugin

	-- Algunos temas se construyen sobre otro plugin y lo declaran en
	-- `dependencies` (p. ej. hackerman hace require("aether").load(...)). Hay que
	-- instalarlas y cargarlas ANTES del colorscheme.
	local deps = {}
	for _, dep in ipairs(plugin.dependencies or {}) do
		deps[#deps + 1] = add_plugin(dep, false)
	end

	-- Plugin del colorscheme del tema activo.
	local name = add_plugin(plugin, true)

	-- Recarga limpia (dependencias + principal) para que los require lean la
	-- revisión recién puesta en disco al alternar versiones en caliente.
	for _, d in ipairs(deps) do
		if d then
			unload_module(d)
		end
	end
	unload_module(name)

	-- Si el tema trae config(), lo ejecutamos como lo haría LazyVim: recibe
	-- (spec, opts) y normalmente hace require(...).setup(opts) + colorscheme.
	-- Acá viven los colores 100% personalizados (aether, monokai-pro, solarized…).
	if type(plugin.config) == "function" and pcall(plugin.config, plugin, plugin.opts or {}) then
		return ""
	end

	-- Tema sin config: aplicamos opts (si hay) y el colorscheme declarado.
	if type(plugin.opts) == "table" and next(plugin.opts) then
		pcall(function()
			require(name).setup(plugin.opts)
		end)
	end
	if not apply_colorscheme(theme.colorscheme) and not apply_colorscheme(name) then
		pcall(vim.cmd.colorscheme, omarchy.fallback)
	end
	return ""
end

_G.OmarchyReloadTheme()
