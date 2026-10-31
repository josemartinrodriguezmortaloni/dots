-- Start screen: mini.starter solo abre el buffer; lua/dashboard.lua dibuja
-- todo el contenido desde su content_hook.

-- Fallbacks para colorschemes que no definen los grupos del dashboard
local DEFAULT_LINKS = {
  MiniStarterDashboardHeader = "MiniStarterHeader",
  MiniStarterDashboardTitle = "MiniStarterSection",
  MiniStarterDashboardDir = "Comment",
  MiniStarterDashboardFile = "MiniStarterItem",
  MiniStarterDashboardIcon = "Special",
  MiniStarterDashboardKey = "MiniStarterItemPrefix",
}

local function set_default_highlights()
  for name, target in pairs(DEFAULT_LINKS) do
    vim.api.nvim_set_hl(0, name, { link = target, default = true })
  end
end

set_default_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("starter_dashboard", { clear = true }),
  callback = set_default_highlights,
})

require("mini.starter").setup({
  autoopen = true,
  evaluate_single = false,
  -- El hook reemplaza este ítem; mini.starter exige al menos uno
  items = { { name = "Dashboard", action = "", section = "" } },
  header = "",
  footer = "",
  content_hooks = { require("dashboard").content_hook },
})
