-- LSP overrides from Work/dots/nvim.
-- Servers themselves come from LazyVim extras (python/typescript/rust/clangd/…).
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
      },
      diagnostics = {
        virtual_text = { spacing = 4, prefix = "●" },
      },
    },
  },
}
