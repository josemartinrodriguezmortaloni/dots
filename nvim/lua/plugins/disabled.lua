return {
  {
    "LazyVim/LazyVim",
    opts = {
      news = {
        lazyvim = false,
        neovim = false,
      },
    },
  },

  -- noice deshabilitado: cmdline, mensajes y popupmenu nativos.
  -- Las notificaciones siguen via snacks.notifier.
  { "folke/noice.nvim", enabled = false },
}
