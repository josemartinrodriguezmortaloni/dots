local keymap = vim.keymap.set

-- Salir de insert mode y guardar/salir
keymap("i", "jk", "<Esc>", { desc = "Salir de insert" })
keymap("i", "ii", "<Esc>", { desc = "Salir de insert" })
keymap("n", "<C-s>", "<cmd>w<cr>", { desc = "Guardar" })
keymap("n", "<leader>ww", "<cmd>w<cr>", { desc = "Guardar" })
keymap("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Guardar y salir" })
keymap("n", "<leader>qq", "<cmd>q!<cr>", { desc = "Salir sin guardar" })

-- Navegación y splits
keymap("n", "<C-a>", "ggVG", { desc = "Seleccionar todo" })
keymap("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Igualar splits" })
keymap("n", "<leader>sx", "<cmd>close<cr>", { desc = "Cerrar split" })

-- Mover líneas
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Mover línea abajo" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Mover línea arriba" })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Mover selección abajo" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Mover selección arriba" })

-- Buffers
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Buffer anterior" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Buffer siguiente" })
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Cerrar buffer" })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternar buffer" })

-- Explorador y utilidades
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Explorador" })
keymap("n", "-", "<cmd>NvimTreeToggle<cr>", { desc = "Explorador" })
keymap("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Historial de cambios" })

-- Fuzzy finder
keymap("n", "<leader>ff", "<cmd>Pick files<cr>", { desc = "Buscar archivos" })
keymap("n", "<leader>fg", "<cmd>Pick grep_live<cr>", { desc = "Buscar texto" })
keymap("n", "<leader>fb", "<cmd>Pick buffers<cr>", { desc = "Buscar buffers" })
keymap("n", "<leader>fh", "<cmd>Pick help<cr>", { desc = "Buscar ayuda" })
keymap("n", "<leader>fr", "<cmd>Pick oldfiles<cr>", { desc = "Archivos recientes" })
keymap("n", "<leader>/", "<cmd>Pick buf_lines<cr>", { desc = "Buscar en buffer" })

-- Terminal nativo
local terminal = require("plugins.terminal")
for key, tipo in pairs({ ["<A-i>"] = "float", ["<A-h>"] = "horizontal", ["<A-v>"] = "vertical" }) do
  keymap({ "n", "t" }, key, function() terminal.toggle(tipo) end, { desc = tipo:gsub("^%l", string.upper) .. " terminal" })
end
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Salir de terminal" })

-- Git
keymap("n", "<leader>gg", function() terminal.send("lazygit", "float") end, { desc = "LazyGit" })

-- Code (requiere LSP)
keymap(
  "n",
  "<leader>co",
  function() require("conform").format({ formatters = { "ruff_organize_imports" }, async = true }) end,
  { desc = "Organizar imports" }
)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local opts = function(desc) return { buffer = buf, desc = desc } end
    keymap("n", "gd", vim.lsp.buf.definition, opts("Ir a definición"))
    keymap("n", "gD", vim.lsp.buf.declaration, opts("Ir a declaración"))
    keymap("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, opts("Formatear"))
    keymap("n", "<leader>cd", vim.diagnostic.open_float, opts("Ver diagnóstico"))
  end,
})
