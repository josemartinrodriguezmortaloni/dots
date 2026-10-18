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
  -- Usamos una statusline propia (ver plugin/statusline.lua)
  { "nvim-lualine/lualine.nvim", enabled = false },
  {
    "folke/noice.nvim", enabled = false
  }
}
