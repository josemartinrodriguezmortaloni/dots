-- Ajustes y ciclo de vida de los servidores LSP. Cada módulo solo llama a
-- vim.lsp.config(); nvim-lspconfig aporta los defaults (lsp/<nombre>.lua) y
-- mason instala los binarios que faltan (plugin/mason.lua).
-- Lo carga plugin/lsp.lua.
for _, module in ipairs({
  "lua_ls",
  "pythonls",
  "jsonls",
  "ts_ls",
  "bashls",
  "dockerls",
  "yamlls",
  "tailwindcss",
}) do
  require("servers." .. module)
end

-- rust-analyzer no va acá: lo arranca rustaceanvim (plugin/rust.lua)
vim.lsp.enable({
  "lua_ls",
  "ty",
  "ruff",
  "jsonls",
  "ts_ls",
  "bashls",
  "dockerls",
  "yamlls",
  "tailwindcss",
  "clangd",
})
