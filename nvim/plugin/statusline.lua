-- Port de la statusline actual de ahmedelgabri/dotfiles (config/nvim/plugin/statusline.lua
-- y lua/_/statusline/*) a un solo archivo.
-- Adaptaciones: gitsigns reemplaza a fugitive (rama) y a mini.diff (resumen de cambios);
-- se omiten jj, oil y fzf porque no están instalados.
-- Solo se dibuja en ventanas que muestran un archivo; sin archivos en el tab no hay statusline.

local ICONS = {
  branch = "\u{e0a0}",
  lock = "\u{e0a2}",
  paste = "⍴",
  spell = "✎",
  conflict = " ",
  lsp = "󰒋",
}

-- Clave "modifiable:readonly" -> etiqueta del segmento de solo lectura
local READONLY_LABELS = {
  ["false:true"] = ICONS.lock .. " RO",
  ["true:true"] = "RO",
  ["false:false"] = ICONS.lock,
}

---Note that: \19 = ^S and \22 = ^V.
---@type table<string, string>
local MODES = {
  no = "N-Operator Pending",
  nov = "N-Operator Block",
  noV = "N-Operator Line",
  v = "V.",
  V = "V·Line",
  ["\22"] = "V·Block",
  s = "S.",
  S = "S·Line",
  ["\19"] = "S·Block",
  i = "I.",
  ic = "I·Compl",
  ix = "I·X-Compl",
  R = "R.",
  Rc = "Compl·Replace",
  Rx = "V·Replace",
  Rv = "X-Compl·Replace",
  c = "Command",
  cv = "Vim Ex",
  ce = "Ex",
  r = "Prompt",
  rm = "More",
  ["r?"] = "Confirm",
  ["!"] = "Sh",
  t = "T.",
  nt = "TN.",
}

-- Campo de vim.b.gitsigns_status_dict -> signo y highlight
local DIFF_PARTS = {
  { key = "added", sign = "+", hl = "StatusLineDiffAdd" },
  { key = "changed", sign = "~", hl = "StatusLineDiffChange" },
  { key = "removed", sign = "-", hl = "StatusLineDiffDelete" },
}

-- Filetypes donde no se buscan marcadores de conflicto
local NO_CONFLICT_SCAN = { ministarter = true, snacks_dashboard = true }

-- Fallbacks para colorschemes que no definen estos grupos; lua/plain.lua los define
local DEFAULT_LINKS = {
  User4 = "Comment",
  User5 = "WarningMsg",
  User6 = "Normal",
  StatusLineModified = "WarningMsg",
  StatusLineDiffAdd = "Added",
  StatusLineDiffChange = "Changed",
  StatusLineDiffDelete = "Removed",
}

local TRANSPARENT_GROUPS = { "StatusLine", "StatusLineNC" }

local NARROW_WINDOW = 80
local MAX_CONFLICTS = 99

local LINE_NO_INDICATOR_CHARS = { "󰋙", "󰫃", "󰫄", "󰫅", "󰫆", "󰫇", "󰫈" }

local M = {}

_G.Statusline = M

---@param parts table<number, any>
---@return string
local function get_parts(parts)
  return table.concat(
    vim.tbl_filter(function(item)
      return type(item) == "string"
    end, parts),
    " "
  )
end

---@param hl string
---@param text string
---@return string
local function paint(hl, text)
  return "%#" .. hl .. "#" .. text .. "%*"
end

---Display lineNoIndicator (from drzel/vim-line-no-indicator)
---@return string
local function line_no_indicator()
  local current, total = vim.fn.line("."), vim.fn.line("$")
  if current == 1 then
    return LINE_NO_INDICATOR_CHARS[1]
  end
  if current == total then
    return LINE_NO_INDICATOR_CHARS[#LINE_NO_INDICATOR_CHARS]
  end
  return LINE_NO_INDICATOR_CHARS[math.ceil(current / total * #LINE_NO_INDICATOR_CHARS)]
end

---@return string?
local function macro_status()
  local register = vim.fn.reg_recording()
  if register == "" then
    return nil
  end
  return paint("ErrorMsg", "󰑊 Recording @" .. register)
end

---@return string?
local function git_info()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return nil
  end
  return paint("User6", ICONS.branch .. " " .. head)
end

---@param summary table
---@param part {key: string, sign: string, hl: string}
---@return string?
local function diff_part(summary, part)
  local count = summary[part.key] or 0
  if count == 0 then
    return nil
  end
  return paint(part.hl, part.sign .. count)
end

---@return string?
local function diff_summary()
  local summary = vim.b.gitsigns_status_dict
  if not summary then
    return nil
  end
  return table.concat(
    vim
      .iter(DIFF_PARTS)
      :map(function(part)
        return diff_part(summary, part)
      end)
      :totable(),
    " "
  )
end

---@param full string ruta relativa al cwd
---@return string
local function dir_prefix(full)
  local base = vim.fn.fnamemodify(full, ":h")
  if base == "" or base == "." then
    return ""
  end
  return base .. "/"
end

---@return string
local function filepath_hl()
  if vim.bo.modified then
    return "StatusLineModified"
  end
  return "User4"
end

---@return string
local function filepath()
  local full = vim.fn.expand("%:~:.")
  local hl = filepath_hl()
  if full == "" then
    return paint(hl, "%f")
  end
  return paint("LineNr", dir_prefix(full)) .. paint(hl, vim.fn.fnamemodify(full, ":t"))
end

---@return string?
local function readonly()
  local label = READONLY_LABELS[tostring(vim.bo.modifiable) .. ":" .. tostring(vim.bo.readonly)]
  if not label then
    return nil
  end
  return "%5* " .. label .. " %w %*"
end

---@return integer
local function conflict_count()
  -- Count "^<<<<<<< " rather than "^=======$": a bare ======= line occurs in
  -- normal text (Markdown/RST setext headings), the start marker does not.
  -- The timeout keeps huge buffers from stalling statusline redraws.
  local result = vim.fn.searchcount({ pattern = [[^<<<<<<< ]], recompute = 1, maxcount = MAX_CONFLICTS, timeout = 50 })
  return result.total or 0
end

---@return string?
local function git_conflicts()
  if NO_CONFLICT_SCAN[vim.bo.filetype] then
    return nil
  end
  local total = conflict_count()
  if total == 0 then
    return nil
  end
  return paint("DiagnosticSignError", ICONS.conflict .. total)
end

---@return string?
local function word_count()
  if vim.bo.filetype ~= "text" then
    return nil
  end
  return paint("User4", vim.fn.wordcount().words .. " words")
end

---@return string?
local function mode()
  local current = vim.api.nvim_get_mode().mode
  if current == "n" then
    return nil
  end
  return MODES[current] or "Unknown"
end

---@return string?
local function paste()
  if not vim.o.paste then
    return nil
  end
  return paint("ErrorMsg", ICONS.paste)
end

---@return string?
local function spell()
  if not vim.wo.spell then
    return nil
  end
  return paint("WarningMsg", ICONS.spell)
end

---@return string?
local function diagnostics()
  local status = vim.diagnostic.status(0)
  if status == "" then
    return nil
  end
  return "‹› " .. status
end

---@return string?
local function busy()
  if vim.bo.busy == 0 then
    return nil
  end
  return "◐ "
end

---@return string
local function lsp_icon()
  local ok, mini_icons = pcall(require, "mini.icons")
  if not ok then
    return ICONS.lsp
  end
  return (mini_icons.get("lsp", "event"))
end

---Sin clientes -> error; con progreso en curso -> warn; inactivo -> comentario
---@return string
local function lsp_hl()
  if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
    return "ErrorMsg"
  end
  if vim.ui.progress_status() ~= "" then
    return "DiagnosticWarn"
  end
  return "Comment"
end

---@return string
local function lsp_progress()
  return paint(lsp_hl(), lsp_icon())
end

---@param value string?
---@param default string
---@return string?
local function unless_default(value, default)
  if value == default then
    return nil
  end
  return value
end

---@return string
local function file_info()
  return get_parts({
    vim.bo.filetype:upper(),
    unless_default(vim.bo.fileformat, "unix"),
    unless_default(vim.bo.fileencoding, "utf-8"),
  })
end

---@return string
local function rhs()
  if vim.fn.winwidth(0) <= NARROW_WINDOW then
    return line_no_indicator()
  end
  local total = vim.fn.line("$")
  local pos = string.format("%" .. #tostring(total) .. "d/%d:%-2d", vim.fn.line("."), total, vim.fn.col("."))
  return get_parts({ paint("User4", pos), paint("User4", line_no_indicator()) })
end

---Buffer normal con nombre: excluye starter, explorador, terminal, help y pickers
---@param buf integer
---@return boolean
local function is_file(buf)
  return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

---@return string
local function render_active()
  return get_parts({
    "%#StatusLine#",
    git_info(),
    filepath(),
    readonly(),
    diff_summary(),
    git_conflicts(),
    "%=",
    macro_status(),
    word_count(),
    mode(),
    paste(),
    spell(),
    diagnostics(),
    busy(),
    lsp_progress(),
    file_info(),
    rhs(),
    "%*",
  })
end

---@return string
local function render_inactive()
  return paint("StatusLineNC", "%f") .. " "
end

---Punto de entrada de 'statusline'; g:statusline_winid es la ventana que se dibuja
---@return string
function M.render()
  local win = vim.g.statusline_winid
  if not is_file(vim.api.nvim_win_get_buf(win)) then
    return ""
  end
  if win ~= vim.api.nvim_get_current_win() then
    return render_inactive()
  end
  return render_active()
end

---------------------------------------------------------------------------------
-- Progreso LSP en la línea de mensajes
---------------------------------------------------------------------------------

---@param ev vim.api.keyset.create_autocmd.callback_args evento LspProgress
---@return table? value con `kind` válido
local function progress_value(ev)
  local value = vim.tbl_get(ev, "data", "params", "value")
  if type(value) ~= "table" or value.kind == nil then
    return nil
  end
  return value
end

---@param client_id integer
---@return string
local function client_name(client_id)
  local client = vim.lsp.get_client_by_id(client_id)
  if not client then
    return "LSP"
  end
  return client.name
end

---@param name string
---@param value table
---@return [string, string][]
local function progress_chunks(name, value)
  local title = string.format("[%s] %d%%: %s ", name, value.percentage or 100, value.title)
  return { { title, "Comment" }, { value.message or "done", "Comment" } }
end

---@param kind string
---@return string
local function progress_status(kind)
  if kind == "end" then
    return "success"
  end
  return "running"
end

---@param ev vim.api.keyset.create_autocmd.callback_args
local function echo_lsp_progress(ev)
  local value = progress_value(ev)
  if not value then
    return
  end
  local name = client_name(ev.data.client_id)
  vim.api.nvim_echo(progress_chunks(name, value), false, {
    id = "lsp." .. ev.data.client_id,
    kind = "progress",
    source = name,
    status = progress_status(value.kind),
  })
end

---------------------------------------------------------------------------------
-- Highlights y autocommands
---------------------------------------------------------------------------------

local function set_default_highlights()
  for name, target in pairs(DEFAULT_LINKS) do
    vim.api.nvim_set_hl(0, name, { link = target, default = true })
  end
end

---@return boolean
local function tab_has_file()
  return vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(win)
    return is_file(vim.api.nvim_win_get_buf(win))
  end)
end

---laststatus=0 oculta la statusline de la última ventana cuando el tab no muestra archivos
local function update_laststatus()
  vim.o.laststatus = tab_has_file() and 2 or 0
end

local function redraw()
  vim.cmd.redrawstatus()
end

vim.o.statusline = "%!v:lua.Statusline.render()"
update_laststatus()

set_default_highlights()
require("transparent").keep("StatusLineTransparent", TRANSPARENT_GROUPS)

local group = vim.api.nvim_create_augroup("MyStatusLine", { clear = true })
local autocmds = {
  { "ColorScheme", set_default_highlights },
  { { "LspAttach", "LspDetach", "Progress" }, redraw },
  { "LspProgress", echo_lsp_progress },
  { "User", redraw, "GitSignsUpdate" },
  -- On RecordingLeave, reg_recording() is still set until after the
  -- autocmd finishes, so defer the redraw to pick up the cleared state.
  { { "RecordingEnter", "RecordingLeave" }, vim.schedule_wrap(redraw) },
  -- Diferido: en WinClosed la ventana sigue en la lista y en BufEnter el buftype puede no estar fijado
  { { "BufWinEnter", "BufEnter", "BufFilePost", "WinClosed", "TabEnter" }, vim.schedule_wrap(update_laststatus) },
}
for _, spec in ipairs(autocmds) do
  vim.api.nvim_create_autocmd(spec[1], { group = group, pattern = spec[3], callback = spec[2] })
end
