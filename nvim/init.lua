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
	pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact",
		"json", "jsonc", "html", "css", "scss", "yaml", "lua", "toml" },
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
	"https://github.com/catppuccin/nvim",
})

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
	"python", "typescript", "tsx", "javascript", "rust", "lua", "vim", "vimdoc",
	"query", "json", "toml", "yaml", "markdown", "markdown_inline", "bash",
	"html", "css", "sql", "dockerfile", "regex",
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
	{ "ff", "files",                       "Archivos" },
	{ "fg", "git_files",                   "Archivos git" },
	{ "fb", "buffers",                     "Buffers" },
	{ "fr", "oldfiles",                    "Recientes" },
	{ "fs", "live_grep",                   "Buscar texto" },
	{ "fw", "grep_cword",                  "Palabra bajo cursor" },
	{ "fc", "commands",                    "Comandos" },
	{ "fk", "keymaps",                     "Keymaps" },
	{ "fh", "helptags",                    "Ayuda" },
	{ "fd", "diagnostics_document",        "Diag (buffer)" },
	{ "fD", "diagnostics_workspace",       "Diag (workspace)" },
	{ "fS", "lsp_live_workspace_symbols",  "Símbolos" },
	{ "f.", "resume",                      "Reabrir picker" },
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
	map({ "n", "t" }, "<A-i>", function() term.toggle("float") end, { desc = "Terminal flotante" })
	map({ "n", "t" }, "<A-h>", function() term.toggle("horizontal") end, { desc = "Terminal horizontal" })
	map({ "n", "t" }, "<A-v>", function() term.toggle("vertical") end, { desc = "Terminal vertical" })
	map("n", "<leader>tn", function() term.new("horizontal") end, { desc = "Nueva terminal" })
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
		if vim.b.disable_autoformat or vim.g.disable_autoformat then return end
		require("conform").format({ async = true, lsp_format = "fallback" })
	end,
})

local function paste_then_format(key)
	return function()
		local reg = vim.v.register
		local count = vim.v.count1
		vim.cmd(('normal! "%s%d%s'):format(reg, count, key))
		if vim.b.disable_autoformat or vim.g.disable_autoformat then return end
		vim.schedule(function()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end)
	end
end
map("n", "p", paste_then_format("p"), { desc = "Pegar + formatear" })
map("n", "P", paste_then_format("P"), { desc = "Pegar encima + formatear" })

map("n", "<leader>lF", function() require("conform").format({ async = true }) end, { desc = "Formatear" })
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
		if not client then return end
		local b = ev.buf
		local kopt = function(desc) return { buffer = b, desc = desc } end

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
				callback = function() vim.lsp.codelens.refresh({ bufnr = b }) end,
			})
			vim.lsp.codelens.refresh({ bufnr = b })
		end

		-- Defaults 0.12 ya provistos: gd, K, grn, gra, grr, gri, grt, grx, <C-s>
		map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, kopt("LSP: code action"))
		map("n", "<leader>lr", vim.lsp.buf.rename, kopt("LSP: rename"))
		map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, kopt("LSP: format"))
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
map("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end, { expr = true })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end, { expr = true })

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

map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Diag: siguiente" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Diag: anterior" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Diag: línea actual" })
map("n", "<leader>ll", vim.diagnostic.setloclist, { desc = "Diag: loclist" })

-- ----------------------------------------------------------------------------
-- 8. OMARCHY THEME INTEGRATION
-- ----------------------------------------------------------------------------
-- Sigue el tema actual de Omarchy. El hook ~/.config/omarchy/hooks/theme-set
-- llama OmarchyReloadTheme() vía --remote-expr en todas las instancias vivas.

require("catppuccin").setup({
	background = { light = "latte", dark = "mocha" },
	integrations = {
		treesitter = true,
		fzf = true,
		native_lsp = { enabled = true },
		mini = { enabled = true },
	},
})

function _G.OmarchyReloadTheme()
	local light_mode = vim.env.HOME .. "/.config/omarchy/current/theme/light.mode"
	vim.o.background = (vim.uv.fs_stat(light_mode) ~= nil) and "light" or "dark"
	pcall(vim.cmd.colorscheme, "catppuccin")
	return ""
end

_G.OmarchyReloadTheme()
