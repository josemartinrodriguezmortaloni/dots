-- omarchy-theme-hotreload forces `vim.o.background = "dark"` before it applies a
-- theme, and Token picks its palette from that option, so the background is set
-- inside config() -- which runs after -- rather than in the spec. Token exposes
-- one colorscheme name per appearance; the light palette is reached through
-- `background`, not through a separate name.
return {
  {
    "ThorstenRhau/token",
    name = "token",
    priority = 1000,
    config = function()
      require("token").setup({})
      vim.o.background = "light"
      vim.cmd.colorscheme("token-meridian")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "token-meridian",
    },
  },
}
