-- Personal keymaps. Loaded by init.lua.

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<C-s>", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>Q", "<cmd>qall!<CR>", { desc = "Force quit" })

-- Windows
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<leader>sc", "<C-w>c", { desc = "Close split" })
map("n", "<leader>so", "<C-w>o", { desc = "Keep only this split" })
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>b", ":ls<CR>:b ", { desc = "Pick buffer" })

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- toggleterm is the only terminal engine: the LazyVim defaults would keep
-- opening Snacks.terminal instances in parallel.
pcall(vim.keymap.del, { "n", "t" }, "<c-/>")
pcall(vim.keymap.del, { "n", "t" }, "<c-_>")
pcall(vim.keymap.del, "n", "<leader>ft")
pcall(vim.keymap.del, "n", "<leader>fT")

-- Explorer
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle File Explorer" })
map("n", "<leader>E", "<cmd>Neotree toggle reveal<CR>", { desc = "Toggle File Explorer in current file" })
