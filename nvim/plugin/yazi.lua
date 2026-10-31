-- Yazi file manager
require("yazi").setup({
  open_for_directories = false,
  keymaps = { show_help = "<f1>" },
  yazi_floating_window_border = "none",
})

local map = vim.keymap.set

map("n", "sf", "<cmd>Yazi<cr>", { desc = "Open Yazi at current file" })
map("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Open the file manager in nvim's working directory" })
map("n", "<c-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume the last yazi session" })
