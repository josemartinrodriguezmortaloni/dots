-- Motor único de terminales.
-- La lógica de resolución por proyecto vive en lua/terminals.lua.
local function terminals()
  return require("terminals")
end

require("toggleterm").setup({
  size = 20,
  direction = "float",
  -- winblend 0 y sin shading: plugin/transparency.lua es el único que escribe
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
})

local map = vim.keymap.set

-- Shell (count 1), tres orientaciones sobre la misma instancia.
map({ "n", "t" }, "<A-i>", "<cmd>1ToggleTerm direction=float<cr>", { desc = "Terminal flotante" })
map({ "n", "t" }, "<A-h>", "<cmd>1ToggleTerm direction=horizontal<cr>", { desc = "Terminal horizontal" })
map({ "n", "t" }, "<A-v>", "<cmd>1ToggleTerm direction=vertical<cr>", { desc = "Terminal vertical" })
map("n", "<leader>tn", function()
  terminals().new_shell()
end, { desc = "Terminal nueva" })

-- Roles: el comando lo resuelve el stack de la raíz del proyecto.
map("n", "<leader>tr", function()
  terminals().toggle("run")
end, { desc = "Run del proyecto" })
map("n", "<leader>tt", function()
  terminals().toggle("test")
end, { desc = "Test del proyecto" })
map("n", "<leader>ts", function()
  terminals().toggle("server")
end, { desc = "Server del proyecto (tmux)" })
map("n", "<leader>tR", function()
  terminals().reset_entrypoint()
end, { desc = "Reelegir entrypoint uv" })
