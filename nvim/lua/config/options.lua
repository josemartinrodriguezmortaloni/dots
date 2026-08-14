-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
require("config.remote_clipboard").setup()

-- Prefer basedpyright (from Work/dots/nvim) over pyright
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.autoformat = true

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
o.clipboard = "unnamedplus"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
