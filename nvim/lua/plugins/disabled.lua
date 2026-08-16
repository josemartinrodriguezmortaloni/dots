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
  -- Usamos mini.statusline (ver minit-statusline.lua)
  { "nvim-lualine/lualine.nvim", enabled = false },
  {
    "folke/noice.nvim", enabled = false
  }
}
