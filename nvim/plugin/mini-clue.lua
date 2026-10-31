-- Pistas de teclas: mini.clue reemplaza a which-key.

local MAX_WIDTH = 45

---@param mark table entrada de getmarklist()
---@return string?
local function mark_desc(mark)
  if mark.file then
    return vim.fn.fnamemodify(mark.file, ":p:~:.")
  end
  local line = vim.fn.getbufline(mark.pos[1], mark.pos[2])[1]
  return line and string.format("%d: %s", mark.pos[2], vim.trim(line))
end

---@param mark table entrada de getmarklist()
---@return table?
local function mark_clue(mark)
  local key = mark.mark:sub(2, 2)
  if not key:match("^%a") then
    return nil
  end
  local desc = mark_desc(mark)
  return desc and { mode = "n", keys = "`" .. key, desc = desc }
end

-- Marcas a-z/A-Z con archivo o línea como descripción
local function mark_clues()
  local marks = vim.list_extend(vim.fn.getmarklist(vim.api.nvim_get_current_buf()), vim.fn.getmarklist())
  return vim
    .iter(marks)
    :unique(function(mark)
      return mark.mark
    end)
    :map(mark_clue)
    :totable()
end

-- Macros grabadas en los registros a-z
local function macro_clues()
  local res = {}
  for register in ("abcdefghijklmnopqrstuvwxyz"):gmatch(".") do
    local desc = vim.fn.getreg(register, 1)
    if desc ~= "" then
      vim.list_extend(res, {
        { mode = "n", keys = '"' .. register, desc = desc },
        { mode = "v", keys = '"' .. register, desc = desc },
      })
    end
  end
  return res
end

---Ancho del contenido más 2 de margen, con tope MAX_WIDTH
---@param bufnr integer
local function window_config(bufnr)
  local widths = vim.tbl_map(vim.fn.strchars, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  return {
    border = "rounded",
    width = math.min(MAX_WIDTH, math.max(0, unpack(widths)) + 2),
  }
end

local clue = require("mini.clue")

clue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "<localleader>" },
    { mode = "x", keys = "<localleader>" },
    { mode = "i", keys = "<C-x>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
  },
  clues = {
    -- Grupos de <leader> definidos en plugin/
    { mode = "n", keys = "<leader>c", desc = "+code" },
    { mode = "n", keys = "<leader>f", desc = "+file/find" },
    { mode = "n", keys = "<leader>s", desc = "+search" },
    { mode = "n", keys = "<leader>t", desc = "+terminal" },
    { mode = "n", keys = "[", desc = "+prev" },
    { mode = "n", keys = "]", desc = "+next" },
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
    clue.gen_clues.square_brackets(),
    mark_clues,
    macro_clues,
  },
  window = {
    delay = 150,
    scroll_down = "<C-f>",
    scroll_up = "<C-b>",
    config = window_config,
  },
})
