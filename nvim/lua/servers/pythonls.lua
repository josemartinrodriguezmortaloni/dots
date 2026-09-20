-- ================================================================================================
-- TITLE : Python LSP Setup — ty (tipos) + ruff (lint/format)
-- LINKS :
--   > ty   : https://github.com/astral-sh/ty        | https://docs.astral.sh/ty/reference/editor-settings/
--   > ruff : https://github.com/astral-sh/ruff      | https://docs.astral.sh/ruff/editors/settings/
-- NOTE  : a ty lo habilita el extra lang.python vía vim.g.lazyvim_python_lsp (lua/config/options.lua);
--         el hover lo sirve ty, porque el extra ya se lo desactiva a ruff.
-- ================================================================================================

vim.lsp.config("ty", {
  settings = {
    ty = {
      diagnosticMode = "openFilesOnly",
      inlayHints = {
        variableTypes = true,
        callArgumentNames = true,
      },
      completions = {
        autoImport = true,
        completeFunctionParentheses = false,
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
})
