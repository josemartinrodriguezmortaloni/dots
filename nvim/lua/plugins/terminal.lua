local M = {}
local terminals = {}

local float_opts = { relative = "editor", row = 0.3, col = 0.25, width = 0.5, height = 0.4, border = "single" }

local function create_float_win(buf)
  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor(ui.width * float_opts.width)
  local height = math.floor(ui.height * float_opts.height)
  local row = math.floor(ui.height * float_opts.row)
  local col = math.floor(ui.width * float_opts.col)
  return vim.api.nvim_open_win(buf, true, {
    relative = float_opts.relative,
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = float_opts.border,
  })
end

local function create_split(tipo)
  if tipo == "horizontal" then
    vim.cmd("botright split")
    vim.cmd("resize " .. math.floor(vim.o.lines * 0.3))
  else
    vim.cmd("botright vsplit")
    vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.5))
  end
end

local function open_terminal(tipo)
  local buf = vim.api.nvim_create_buf(false, true)
  local win
  if tipo == "float" then
    win = create_float_win(buf)
  else
    create_split(tipo)
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
  end
  vim.fn.termopen("zsh")
  vim.cmd("startinsert")
  terminals[tipo] = { buf = buf, win = win }
end

function M.toggle(tipo)
  local term = terminals[tipo]
  if term and vim.api.nvim_buf_is_valid(term.buf) then
    if term.win and vim.api.nvim_win_is_valid(term.win) then
      vim.api.nvim_win_close(term.win, true)
      term.win = nil
      return
    end
    if tipo == "float" then
      term.win = create_float_win(term.buf)
    else
      create_split(tipo)
      term.win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(term.win, term.buf)
    end
    vim.cmd("startinsert")
    return
  end
  open_terminal(tipo)
end

function M.send(cmd, tipo)
  M.toggle(tipo)
  local term = terminals[tipo]
  if term and vim.api.nvim_buf_is_valid(term.buf) then
    local chan = vim.bo[term.buf].channel
    if chan then vim.fn.chansend(chan, cmd .. "\r") end
  end
end

return M
