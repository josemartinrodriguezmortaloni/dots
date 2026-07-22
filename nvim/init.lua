-- ============================================================================
-- init.lua — Neovim 0.12+ en un solo archivo (≤ 300 líneas)
-- Stack: vim.pack + LSP/completado nativos + treesitter + fzf-lua + conform +
-- mini.nvim. El colorscheme lo pone el tema activo de Omarchy (sección 8).
-- ============================================================================

-- ── 1. OPTIONS ──────────────────────────────────────────────────────────────

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.o
o.number, o.relativenumber, o.cursorline, o.signcolumn = true, true, true, "yes"
o.scrolloff, o.sidescrolloff, o.wrap, o.list = 8, 8, false, true
o.termguicolors, o.showmode, o.laststatus = true, false, 3
o.splitright, o.splitbelow = true, true
o.pumheight, o.winborder, o.pumborder = 12, "rounded", "rounded"
o.expandtab, o.smartindent = true, true -- indent 4; baja a 2 por filetype (autocmds)
o.tabstop, o.shiftwidth, o.softtabstop = 4, 4, 4
o.ignorecase, o.smartcase = true, true
o.undofile, o.swapfile, o.updatetime, o.timeoutlen = true, false, 250, 400
o.autocomplete = true -- completado nativo 0.12
o.completeopt = "menu,menuone,noselect,popup,nearest"
o.shortmess = o.shortmess .. "c"
o.clipboard = "unnamedplus"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

-- ── 2. KEYMAPS BASE ─────────────────────────────────────────────────────────

local map = vim.keymap.set
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Guardar" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Salir" })
map("n", "<leader>Q", "<cmd>qall!<CR>", { desc = "Salir forzado" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>sc", "<C-w>c", { desc = "Cerrar split" })
map("n", "<leader>so", "<C-w>o", { desc = "Solo este split" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Buffer siguiente" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Buffer anterior" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Cerrar buffer" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: modo normal" })
map("n", "<leader>pu", function() vim.pack.update() end, { desc = "Pack: actualizar" })

-- ── 3. AUTOCMDS ─────────────────────────────────────────────────────────────

local function aug(name) return vim.api.nvim_create_augroup(name, { clear = true }) end

vim.api.nvim_create_autocmd("BufWritePre", {
	group = aug("trim-whitespace"),
	callback = function()
		if vim.bo.filetype == "markdown" or vim.bo.filetype == "diff" then return end
		local view = vim.fn.winsaveview()
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = aug("web-indent"),
	pattern = vim.split("javascript typescript javascriptreact typescriptreact json jsonc html css scss yaml lua toml", " "),
	callback = function()
		vim.bo.tabstop, vim.bo.shiftwidth, vim.bo.softtabstop = 2, 2, 2
	end,
})

-- ── 4. PLUGINS (vim.pack, gestor nativo) ────────────────────────────────────
-- El plugin del colorscheme no va acá: lo instala la sección 8 (solo el del
-- tema Omarchy activo).

vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/nvim-tree/nvim-tree.lua.git",
	"https://github.com/nvim-tree/nvim-web-devicons.git",
})

-- mini.nvim: cherry-picking de módulos
for _, m in ipairs({ "icons", "pairs", "surround", "ai", "statusline", "diff" }) do
	require("mini." .. m).setup()
end
require("mini.icons").mock_nvim_web_devicons()
map("n", "<leader>go", function() require("mini.diff").toggle_overlay(0) end, { desc = "Git: toggle overlay" })

-- Treesitter (rama main): parsers + highlight/indent por buffer
local ts_langs = "python typescript tsx javascript rust lua vim vimdoc query c cpp json toml yaml"
	.. " markdown markdown_inline bash html css sql dockerfile regex"
require("nvim-treesitter").install(vim.split(ts_langs, " "))
vim.treesitter.language.register("json", "jsonc")
vim.api.nvim_create_autocmd("FileType", {
	group = aug("treesitter-start"),
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
	end,
})

-- fzf-lua: buscador universal
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
	{ "f.", "resume", "Reabrir picker" },
}) do
	map("n", "<leader>" .. m[1], "<cmd>FzfLua " .. m[2] .. "<CR>", { desc = m[3] })
end

-- ── 5. FORMATEO (conform.nvim) ──────────────────────────────────────────────

local formatters_by_ft = { python = { "ruff_format", "ruff_organize_imports" }, lua = { "stylua" }, rust = { "rustfmt" } }
formatters_by_ft.c, formatters_by_ft.cpp = { "clang-format" }, { "clang-format" }
for _, ft in ipairs(vim.split("javascript typescript javascriptreact typescriptreact json jsonc css scss html markdown yaml", " ")) do
	formatters_by_ft[ft] = { "prettier" }
end

require("conform").setup({
	formatters_by_ft = formatters_by_ft,
	format_on_save = function(buf)
		if vim.b[buf].disable_autoformat or vim.g.disable_autoformat then return end
		return { lsp_format = "fallback", timeout_ms = 1500 }
	end,
})
map("n", "<leader>lF", function() require("conform").format({ async = true }) end, { desc = "Formatear" })
map("n", "<leader>lT", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	vim.notify("Autoformat " .. (vim.b.disable_autoformat and "OFF" or "ON") .. " (buffer)")
end, { desc = "Toggle autoformat (buffer)" })

-- ── 6. LSP (API nativa 0.12) — agregar un server = una entrada acá ──────────

local servers = {
	basedpyright = {
		cmd = { "basedpyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
		settings = { basedpyright = { analysis = { typeCheckingMode = "standard", diagnosticMode = "openFilesOnly" } } },
	},
	vtsls = {
		cmd = { "vtsls", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { "package.json", "tsconfig.json", ".git" },
	},
	clangd = {
		cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
		root_markers = { ".clangd", "compile_commands.json", "CMakeLists.txt", ".git" },
	},
	rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", ".git" },
		settings = { ["rust-analyzer"] = { check = { command = "clippy" }, cargo = { allFeatures = true } } },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".git" },
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME .. "/lua" } },
				diagnostics = { globals = { "vim" } },
			},
		},
	},
}
for name, cfg in pairs(servers) do
	vim.lsp.config(name, cfg)
end
vim.lsp.enable(vim.tbl_keys(servers))

-- Keymaps LSP default de 0.12 ya provistos: gd, K, grn, gra, grr, gri, grt, <C-s>
vim.api.nvim_create_autocmd("LspAttach", {
	group = aug("lsp-attach"),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

-- Popup de completado: <CR> confirma, Tab/S-Tab navegan
map("i", "<CR>", function()
	if vim.fn.pumvisible() == 0 then return "<CR>" end
	return vim.fn.complete_info({ "selected" }).selected ~= -1 and "<C-y>" or "<C-e><CR>"
end, { expr = true })
map("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end, { expr = true })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end, { expr = true })

-- ── 7. DIAGNÓSTICOS ─────────────────────────────────────────────────────────
-- ]d, [d y <C-w>d ya son defaults; winborder="rounded" redondea los floats.

vim.diagnostic.config({
	virtual_text = { spacing = 4, prefix = "●" },
	signs = { text = { "E", "W", "I", "H" } }, -- índices 1..4 = ERROR..HINT
	severity_sort = true,
	float = { source = true },
})
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Diag: línea actual" })

-- ── 8. TEMA OMARCHY ─────────────────────────────────────────────────────────
-- Neovim sigue el tema activo: su neovim.lua trae un spec estilo lazy.nvim con
-- el plugin del colorscheme; lo instalamos con vim.pack y aplicamos su config.
-- El hook theme-set de Omarchy invoca OmarchyReloadTheme() por RPC. Sin sync
-- de branches git: si dos temas comparten plugin en ramas distintas, cambiar
-- entre ellos requiere reiniciar nvim.

local theme_dir = vim.env.HOME .. "/.config/omarchy/current/theme"

local function pack_theme(spec)
	local t = type(spec) == "table" and spec or { spec }
	if type(t[1]) ~= "string" then return nil end
	local name = t.name or t[1]:match("([^/]+)$")
	pcall(vim.pack.add, { { src = "https://github.com/" .. t[1], name = name, version = t.branch or t.tag or t.commit } })
	return name
end

local function try_colorscheme(name)
	return type(name) == "string" and (pcall(vim.cmd.colorscheme, name) or pcall(vim.cmd.colorscheme, (name:gsub("%-nvim$", ""))))
end

function _G.OmarchyReloadTheme()
	vim.o.background = vim.uv.fs_stat(theme_dir .. "/light.mode") and "light" or "dark"
	local ok, spec = pcall(loadfile(theme_dir .. "/neovim.lua") or function() end)
	local entries = ok and type(spec) == "table" and (type(spec[1]) == "string" and { spec } or spec) or {}
	local plugin, colorscheme
	for _, e in ipairs(entries) do
		if type(e) == "table" and e[1] == "LazyVim/LazyVim" then
			colorscheme = type(e.opts) == "table" and e.opts.colorscheme or nil
		elseif type(e) == "table" and type(e[1]) == "string" then
			plugin = e
		end
	end
	if not plugin then return pcall(vim.cmd.colorscheme, "default") end
	for _, dep in ipairs(plugin.dependencies or {}) do
		pack_theme(dep)
	end
	local name = pack_theme(plugin)
	package.loaded[name or ""] = nil
	if type(plugin.config) == "function" and pcall(plugin.config, plugin, plugin.opts or {}) then return end
	if type(plugin.opts) == "table" and next(plugin.opts) then pcall(function() require(name).setup(plugin.opts) end) end
	if not (try_colorscheme(colorscheme) or try_colorscheme(name)) then pcall(vim.cmd.colorscheme, "default") end
end
_G.OmarchyReloadTheme()

-- ── 9. TERMINAL FLOTANTE (<A-i>) ────────────────────────────────────────────

local term = {}
map({ "n", "t" }, "<A-i>", function()
	if term.win and vim.api.nvim_win_is_valid(term.win) then
		vim.api.nvim_win_hide(term.win)
		term.win = nil
		return
	end
	if not (term.buf and vim.api.nvim_buf_is_valid(term.buf)) then term.buf = vim.api.nvim_create_buf(false, true) end
	local W, H = vim.o.columns, vim.o.lines
	local cfg = { relative = "editor", border = "rounded", width = math.floor(W * 0.7), height = math.floor(H * 0.7) }
	cfg.row, cfg.col = math.floor(H * 0.15), math.floor(W * 0.15)
	term.win = vim.api.nvim_open_win(term.buf, true, cfg)
	if vim.bo[term.buf].buftype ~= "terminal" then vim.fn.jobstart(o.shell, { term = true }) end
	vim.cmd.startinsert()
end, { desc = "Terminal flotante" })

-- ── 10. NVIM-TREE (<leader>e) ────────────────────────────────────────────

require("nvim-tree").setup()
map("n", "<leader>e", "<cr>:NvimTreeToggle<cr>")
