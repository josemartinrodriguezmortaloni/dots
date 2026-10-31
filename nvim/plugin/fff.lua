-- fff.nvim: file find + live grep
-- Repo: https://github.com/dmtrKovalenko/fff.nvim
-- El plugin se auto-inicializa desde vim.g.fff; sin overrides no hace falta setup().
local function fff(method, opts)
  return function()
    require("fff")[method](opts and opts())
  end
end

local function cwd()
  return { cwd = vim.fn.getcwd() }
end

local map = vim.keymap.set

map("n", "<leader><space>", fff("find_files"), { desc = "Find Files (fff)" })
map("n", "<leader>/", fff("live_grep"), { desc = "Grep (fff)" })
map("n", "<leader>ff", fff("find_files"), { desc = "Find Files (fff)" })
map("n", "<leader>fF", function()
  require("fff").find_files_in_dir(vim.fn.getcwd())
end, { desc = "Find Files cwd (fff)" })
map("n", "<leader>sg", fff("live_grep"), { desc = "Grep (fff)" })
map("n", "<leader>sG", fff("live_grep", cwd), { desc = "Grep cwd (fff)" })
map({ "n", "x" }, "<leader>sw", fff("live_grep_under_cursor"), { desc = "Word / selection (fff)" })
map({ "n", "x" }, "<leader>sW", fff("live_grep_under_cursor", cwd), { desc = "Word / selection cwd (fff)" })
