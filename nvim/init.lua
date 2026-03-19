-- Neovim Config | Requiere: Neovim >= 0.11, Nerd Font
vim.loader.enable()

require("config.options")
require("plugins")
require("config.keymaps")
require("config.autocmds")

-- LSP
vim.lsp.enable({
  "lua_ls",
  "basedpyright",
  "ruff",
  "bashls",
  "clangd",
  "cssls",
  "eslint",
  "html",
  "jdtls",
  "jsonls",
  "rust_analyzer",
  "tailwindcss",
  "tsgo",
})
vim.lsp.document_color.enable(true, 0, { style = "virtual" })
