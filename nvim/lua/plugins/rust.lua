-- rust-analyzer corre bajo rustaceanvim (extra lang.rust); el binario es del sistema.
-- Override: usar clippy en vez de cargo check para los diagnósticos al guardar.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
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
    },
  },
}
