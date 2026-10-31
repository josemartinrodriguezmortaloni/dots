-- ================================================================================================
-- TITLE : Python LSP Setup — ty (tipos) + ruff (lint/format)
-- LINKS :
--   > ty   : https://github.com/astral-sh/ty        | https://docs.astral.sh/ty/reference/editor-settings/
--   > ruff : https://github.com/astral-sh/ruff      | https://docs.astral.sh/ruff/editors/settings/
-- NOTE  : los dos los habilita lua/servers/init.lua; el hover lo sirve ty, así que ruff no
--         anuncia hoverProvider.
-- ================================================================================================

vim.lsp.config("ty", {
  settings = {
    ty = {
      diagnosticMode = "openFilesOnly",
      inlayHints = {
        variableTypes = false,
        callArgumentNames = true,
      },
      completions = {
        autoImport = true,
        completeFunctionParentheses = true,
      },
    },
  },
})

vim.lsp.config("ruff", {
  init_options = {
    settings = {
      lineLength = 88,
      organizeImports = true,
      fixAll = true,
    },
  },
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})
