-- Token expone un solo nombre de colorscheme por diseño; la paleta clara sale de
-- 'background', que nvim fija desde el `mode` de colors.toml (lua/omarchy/mode.lua).
return {
  {
    "ThorstenRhau/token",
    name = "token",
    priority = 1000,
    config = function()
      require("token").setup({})
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "token-meridian",
    },
  },
}
