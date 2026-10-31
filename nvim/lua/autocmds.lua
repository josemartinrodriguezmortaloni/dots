-- Autocmds propios. Los carga init.lua.

local function aug(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Trim trailing whitespace (from Work/dots/nvim)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = aug("trim_whitespace"),
  callback = function()
    if vim.bo.filetype == "markdown" or vim.bo.filetype == "diff" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Indent 2 for web / config filetypes (from Work/dots/nvim)
vim.api.nvim_create_autocmd("FileType", {
  group = aug("web_indent"),
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

-- Resaltado al copiar con IncSearch
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug("highlight_yank"),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch" })
  end,
})

-- Revisar la ortografía en español.
vim.api.nvim_create_autocmd("FileType", {
  group = aug("spell_lang"),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spelllang = { "es" }
  end,
})