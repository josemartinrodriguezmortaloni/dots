-- Formateo al guardar; los binarios los instala mason (plugin/mason.lua)
local PRETTIER_FILETYPES = {
  "css",
  "graphql",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "markdown",
  "scss",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

local formatters_by_ft = {
  c = { "clang-format" },
  cpp = { "clang-format" },
  lua = { "stylua" },
  python = { "ruff_organize_imports", "ruff_format" },
}

for _, ft in ipairs(PRETTIER_FILETYPES) do
  formatters_by_ft[ft] = { "prettier" }
end

require("conform").setup({
  formatters_by_ft = formatters_by_ft,
  format_on_save = { timeout_ms = 3000, lsp_format = "fallback" },
})
