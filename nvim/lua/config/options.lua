vim.g.mapleader = " "
vim.opt.mouse, vim.opt.confirm, vim.opt.timeoutlen, vim.opt.updatetime = "a", true, 300, 250
vim.opt.swapfile, vim.opt.undofile = false, true
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)

-- Interfaz
vim.opt.number, vim.opt.relativenumber, vim.opt.cursorline = true, true, true
vim.opt.splitright, vim.opt.splitbelow, vim.opt.signcolumn = true, true, "yes"
vim.opt.winborder, vim.opt.pumborder, vim.opt.scrolloff = "bold", "bold", 999
vim.opt.list, vim.opt.listchars = true, { tab = "  ", trail = "·", nbsp = "␣" }

-- Edición
vim.opt.wrap, vim.opt.expandtab, vim.opt.tabstop, vim.opt.shiftwidth = false, true, 2, 2
vim.opt.smartcase, vim.opt.ignorecase, vim.opt.smartindent = true, true, true
vim.opt.inccommand, vim.opt.virtualedit = "split", "block"
vim.opt.wildmode, vim.opt.completeopt = "noselect:lastused,full", "menuone,noinsert,preview,fuzzy"
vim.opt.iskeyword, vim.opt.grepprg = "@,48-57,_,192-255,-", "rg --vimgrep"

-- Diagnósticos
vim.diagnostic.config({
  signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },
  underline = { severity = { min = "HINT", max = "ERROR" } },
  virtual_text = { current_line = true, severity = { min = "ERROR", max = "ERROR" } },
})
