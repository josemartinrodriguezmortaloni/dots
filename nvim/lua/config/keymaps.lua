-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Salir forzado de todo (LazyVim ya trae <leader>qq para salir y <C-s> para guardar)
map("n", "<leader>Q", "<cmd>qall!<CR>", { desc = "Salir forzado (todo)" })

-- Quitar highlight de búsqueda
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Quitar highlight" })

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Guardar" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Salir" })
map("n", "<leader>Q", "<cmd>qall!<CR>", { desc = "Salir forzado" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Quitar highlight" })

-- Ventanas
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>sc", "<C-w>c", { desc = "Cerrar split" })
map("n", "<leader>so", "<C-w>o", { desc = "Solo este split" })

-- Buffers
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Buffer siguiente" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Buffer anterior" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Cerrar buffer" })

-- Visual
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Scroll y búsqueda centrada
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: modo normal" })

-- Pegar y autoformatear (respeta el toggle de autoformato de LazyVim: vim.b/g.autoformat)
local function paste_then_format(key)
  return function()
    local reg = vim.v.register
    local count = vim.v.count1
    vim.cmd(('normal! "%s%d%s'):format(reg, count, key))
    if vim.b.autoformat == false or vim.g.autoformat == false then
      return
    end
    vim.schedule(function()
      require("conform").format({ async = true, lsp_format = "fallback" })
    end)
  end
end
map("n", "p", paste_then_format("p"), { desc = "Pegar + formatear" })
map("n", "P", paste_then_format("P"), { desc = "Pegar encima + formatear" })
