-- rust-analyzer corre bajo rustaceanvim; el binario es del sistema.
-- Override: usar clippy en vez de cargo check para los diagnósticos al guardar.
-- rustaceanvim lee vim.g.rustaceanvim al abrir el primer buffer de Rust.
vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy",
          extraArgs = { "--no-deps" },
        },
        inlayHints = {
          lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
        },
      },
    },
  },
}
