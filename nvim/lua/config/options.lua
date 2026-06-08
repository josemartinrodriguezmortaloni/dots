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
