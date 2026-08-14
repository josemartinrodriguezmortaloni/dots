-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here (from Work/dots/nvim; sin pisar LazyVim)

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Guardar" })
map("n", "<leader>Q", "<cmd>qall!<CR>", { desc = "Salir forzado" })

map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>sc", "<C-w>c", { desc = "Cerrar split" })
map("n", "<leader>so", "<C-w>o", { desc = "Solo este split" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Terminal flotante (equivalente a <A-i> de la config vieja; usa Snacks)
map({ "n", "t" }, "<A-i>", function()
  Snacks.terminal()
end, { desc = "Terminal flotante" })
