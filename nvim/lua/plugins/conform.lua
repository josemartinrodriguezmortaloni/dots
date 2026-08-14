-- Formatters from Work/dots/nvim (prettier/ruff/stylua vienen de LazyVim + extras)
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
    },
  },
}
