-- Terminales integradas via snacks.terminal (reemplaza NvChad/nvterm).
-- `env` distingue cada dirección: forma parte del id de la terminal, así
-- cada keymap mantiene su propia instancia en vez de togglear la misma.
local layouts = {
  float = { position = "float", border = "rounded", width = 0.7, height = 0.7 },
  horizontal = { position = "bottom", height = 0.3 },
  vertical = { position = "right", width = 0.5 },
}

local function toggle(kind)
  Snacks.terminal.toggle(nil, { env = { NVIM_TERM = kind }, win = layouts[kind] })
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<A-i>",
        function()
          toggle("float")
        end,
        mode = { "n", "t" },
        desc = "Terminal flotante",
      },
      {
        "<A-h>",
        function()
          toggle("horizontal")
        end,
        mode = { "n", "t" },
        desc = "Terminal horizontal",
      },
      {
        "<A-v>",
        function()
          toggle("vertical")
        end,
        mode = { "n", "t" },
        desc = "Terminal vertical",
      },
      {
        "<leader>tn",
        function()
          Snacks.terminal.open(nil, { win = layouts.horizontal })
        end,
        desc = "Nueva terminal",
      },
    },
  },
}
