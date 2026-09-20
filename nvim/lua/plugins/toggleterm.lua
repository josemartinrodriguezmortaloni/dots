-- Motor único de terminales: reemplaza a snacks.terminal.
-- La lógica de resolución por proyecto vive en lua/config/terminals.lua.
local function terminals()
  return require("config.terminals")
end

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      direction = "float",
      -- winblend 0 y sin shading: transparency.lua es el único que escribe
      -- Normal/NormalFloat de estos buffers.
      float_opts = { border = "curved", winblend = 0 },
      shade_terminals = false,
      start_in_insert = true,
      persist_mode = true,
      persist_size = true,
      autochdir = false,
      hide_numbers = true,
      close_on_exit = true,
      auto_scroll = true,
    },
    keys = {
      -- Shell (count 1), tres orientaciones sobre la misma instancia.
      { "<A-i>", "<cmd>1ToggleTerm direction=float<cr>", mode = { "n", "t" }, desc = "Terminal flotante" },
      { "<A-h>", "<cmd>1ToggleTerm direction=horizontal<cr>", mode = { "n", "t" }, desc = "Terminal horizontal" },
      { "<A-v>", "<cmd>1ToggleTerm direction=vertical<cr>", mode = { "n", "t" }, desc = "Terminal vertical" },
      {
        "<leader>tn",
        function()
          terminals().new_shell()
        end,
        desc = "Terminal nueva",
      },
      -- Roles: el comando lo resuelve el stack de la raíz del proyecto.
      {
        "<leader>tr",
        function()
          terminals().toggle("run")
        end,
        desc = "Run del proyecto",
      },
      {
        "<leader>tt",
        function()
          terminals().toggle("test")
        end,
        desc = "Test del proyecto",
      },
      {
        "<leader>ts",
        function()
          terminals().toggle("server")
        end,
        desc = "Server del proyecto (tmux)",
      },
      {
        "<leader>tR",
        function()
          terminals().reset_entrypoint()
        end,
        desc = "Reelegir entrypoint uv",
      },
    },
  },
}
