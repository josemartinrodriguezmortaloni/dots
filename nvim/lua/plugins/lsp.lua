-- Los servidores vienen de los extras de LazyVim (lang.python -> ty + ruff,
-- lang.rust -> rustaceanvim, lang.clangd -> clangd); el de Python lo elige
-- vim.g.lazyvim_python_lsp en lua/config/options.lua.
-- El ajuste fino de cada servidor vive en lua/servers/<nombre>.lua.
return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      require("servers")
    end,
    opts = {
      diagnostics = {
        virtual_text = { spacing = 4, prefix = "●" },
      },
    },
  },
}
