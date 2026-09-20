-- Ajustes de servidores. Cada módulo solo llama a vim.lsp.config(): el ciclo de vida
-- (instalación con mason y vim.lsp.enable) lo resuelve LazyVim desde opts.servers.
-- Lo carga lua/plugins/lsp.lua en su init, antes de que LazyVim aplique sus propios opts.
for _, module in ipairs({
  "lua_ls",
  "pythonls",
  "gopls",
  "jsonls",
  "ts_ls",
  "bashls",
  "dockerls",
  "emmet_ls",
  "yamlls",
  "tailwindcss",
}) do
  require("servers." .. module)
end
