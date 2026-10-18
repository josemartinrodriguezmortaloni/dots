-- Port de la statusline de ahmedelgabri/dotfiles@638ffd1
-- (config/nvim/plugin/statusline.lua + lua/_/statusline/*), montada sobre mini.statusline.
-- Adaptaciones: gitsigns reemplaza a fugitive y mini.diff; sin segmento jj.

local ICONS = {
  paste = "⍴",
  spell = "✎",
  branch = "\u{e65d}",
  lock = "\u{e0a2}",
  conflict = "\u{ebda} ",
  lsp_fallback = "󰒋",
}

local LINE_NO_INDICATOR_CHARS = { "󰋙", "󰫃", "󰫄", "󰫅", "󰫆", "󰫇", "󰫈" }

-- Grupos que el colorscheme original define; aquí son links que un tema puede pisar
local HIGHLIGHT_LINKS = {
  User4 = "StatusLine",
  User5 = "WarningMsg",
  User6 = "Special",
  StatusLineModified = "DiagnosticWarn",
  StatusLineDiffAdd = "Added",
  StatusLineDiffChange = "Changed",
  StatusLineDiffDelete = "Removed",
}

local DIFF_PARTS = {
  { key = "added", hl = "StatusLineDiffAdd", sign = "+" },
  { key = "changed", hl = "StatusLineDiffChange", sign = "~" },
  { key = "removed", hl = "StatusLineDiffDelete", sign = "-" },
}

-- Clave: "<modifiable>:<readonly>"
local READONLY_LABELS = {
  ["false:true"] = ICONS.lock .. " RO",
  ["true:true"] = "RO",
  ["false:false"] = ICONS.lock,
}

-- Note that: \19 = ^S and \22 = ^V.
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

-- Grupos de la barra sin fondo: se ve el fondo de la terminal
local TRANSPARENT_GROUPS = { "StatusLine", "StatusLineNC" }

-- Filetypes con statusline fija
local FIXED_STATUSLINE = {
  help = "%#StatusLineNC#%t%*",
  man = "%#StatusLineNC#%t%*",
  ministarter = "",
}

---@param item any
---@return boolean
local function is_visible_part(item)
  return type(item) == "string" and item ~= ""
end

---@param parts table<number, any>
---@return string
local function get_parts(parts)
  return table.concat(vim.tbl_filter(is_visible_part, parts), " ")
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
local function git_info()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return nil
  end
  return string.format("%%#User6#%s %s%%*", ICONS.branch, head)
end

---@param summary table
---@param part {key: string, hl: string, sign: string}
---@return string?
local function diff_part(summary, part)
  local count = summary[part.key] or 0
  if count == 0 then
    return nil
  end
  return string.format("%%#%s#%s%d%%*", part.hl, part.sign, count)
end

---@return string?
local function diff_summary()
  local summary = vim.b.gitsigns_status_dict
  if not summary then
    return nil
  end
  local parts = vim.iter(DIFF_PARTS):map(function(part)
    return diff_part(summary, part)
  end)
  return table.concat(parts:totable(), " ")
end

---@return string
local function filename_hl()
  return vim.bo.modified and "StatusLineModified" or "User4"
end

---Solo el nombre del archivo, sin directorio
---@return string
local function filename()
  return string.format("%%#%s#%%t%%*", filename_hl())
end

---@return string?
local function readonly()
  local label = READONLY_LABELS[tostring(vim.bo.modifiable) .. ":" .. tostring(vim.bo.readonly)]
  if not label then
    return nil
  end
  return string.format("%%5* %s %%w %%*", label)
end

---@return string?
local function git_conflicts()
  -- Count "^<<<<<<< " rather than "^=======$": a bare ======= line occurs in
  -- normal text (Markdown/RST setext headings), the start marker does not.
  -- The timeout keeps huge buffers from stalling statusline redraws.
  local result = vim.fn.searchcount({ pattern = [[^<<<<<<< ]], recompute = 1, maxcount = 99, timeout = 50 })
  if (result.total or 0) == 0 then
    return nil
  end
  return string.format("%%#DiagnosticSignError#%s%s%%*", ICONS.conflict, result.total)
end

---@return string?
local function macro_status()
  local register = vim.fn.reg_recording()
  if register == "" then
    return nil
  end
  return string.format("%%#ErrorMsg#󰑊 Recording @%s%%*", register)
end

---@return string?
local function word_count()
  if vim.bo.filetype ~= "text" then
    return nil
  end
  return string.format("%%#User4#%d words%%*", vim.fn.wordcount().words)
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
  return string.format("%%#ErrorMsg#%s%%*", ICONS.paste)
end

---@return string?
local function spell()
  if not vim.wo.spell then
    return nil
  end
  return string.format("%%#WarningMsg#%s%%*", ICONS.spell)
end

---@return string?
local function lsp_diagnostics()
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
local function lsp_progress_hl()
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
  local ok, mini_icons = pcall(require, "mini.icons")
  local icon = ok and mini_icons.get("lsp", "event") or ICONS.lsp_fallback
  return string.format("%%#%s#%s%%*", lsp_progress_hl(), icon)
end

---Devuelve `value` salvo que sea el valor por defecto, que se oculta
---@param value string
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
  if vim.fn.winwidth(0) <= 80 then
    return line_no_indicator()
  end
  local total = vim.fn.line("$")
  local pos = string.format("%" .. #tostring(total) .. "d/%d:%-2d", vim.fn.line("."), total, vim.fn.col("."))
  return get_parts({ "%#User4#" .. pos .. "%*", "%#User4#" .. line_no_indicator() .. "%*" })
end

---@return string
local function render_active()
  local fixed = FIXED_STATUSLINE[vim.bo.filetype]
  if fixed then
    return fixed
  end
  return get_parts({
    "%#Statusline#",
    git_info(),
    filename(),
    readonly(),
    diff_summary(),
    git_conflicts(),
    "%=",
    macro_status(),
    word_count(),
    mode(),
    paste(),
    spell(),
    lsp_diagnostics(),
    busy(),
    lsp_progress(),
    file_info(),
    rhs(),
    "%*",
  })
end

---@return string
local function render_inactive()
  return "%#StatusLineNC#%t%* "
end

local function set_highlights()
  for name, link in pairs(HIGHLIGHT_LINKS) do
    vim.api.nvim_set_hl(0, name, { link = link, default = true })
  end
end

local function redraw_status()
  vim.cmd.redrawstatus()
end

---@param id integer
---@return string
local function lsp_client_name(id)
  local client = vim.lsp.get_client_by_id(id)
  return client and client.name or "LSP"
end

---@param ev table LspProgress event
---@return table?
local function lsp_progress_value(ev)
  local value = vim.tbl_get(ev, "data", "params", "value")
  if type(value) ~= "table" or value.kind == nil then
    return nil
  end
  return value
end

---@param kind string
---@return string
local function echo_status(kind)
  if kind == "end" then
    return "success"
  end
  return "running"
end

---@param name string
---@param value table
---@return table
local function lsp_progress_chunks(name, value)
  return {
    { string.format("[%s] %d%%: %s ", name, value.percentage or 100, value.title), "Comment" },
    { value.message or "done", "Comment" },
  }
end

-- Reemite el progreso LSP como mensaje `progress`, que alimenta vim.ui.progress_status()
---@param ev table LspProgress event
local function echo_lsp_progress(ev)
  local value = lsp_progress_value(ev)
  if not value then
    return
  end
  local name = lsp_client_name(ev.data.client_id)
  vim.api.nvim_echo(lsp_progress_chunks(name, value), false, {
    id = "lsp." .. ev.data.client_id,
    kind = "progress",
    source = name,
    status = echo_status(value.kind),
  })
end

local function create_redraw_autocmds()
  local group = vim.api.nvim_create_augroup("MyStatusLine", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
  vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "Progress" }, { group = group, callback = redraw_status })
  vim.api.nvim_create_autocmd("LspProgress", { group = group, callback = echo_lsp_progress })
  vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = group,
    -- On RecordingLeave, reg_recording() is still set until after the
    -- autocmd finishes, so defer the redraw to pick up the cleared state.
    callback = function()
      vim.schedule(redraw_status)
    end,
  })
end

-- Filetypes de start screen donde la barra se oculta
local HIDE_FT = {
  ministarter = true,
  dashboard = true,
  alpha = true,
  snacks_dashboard = true,
}

local function sync_statusline()
  if HIDE_FT[vim.bo.filetype] then
    vim.b.ministatusline_disable = true
    vim.o.laststatus = 0
  else
    vim.o.laststatus = vim.g.ministatusline_laststatus or 3
  end
end

return {
  "nvim-mini/mini.statusline",
  version = false,
  init = function()
    -- Guardar laststatus y ocultar la barra en el start screen (sin args)
    vim.g.ministatusline_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,
  opts = {
    content = {
      active = render_active,
      inactive = render_inactive,
    },
  },
  config = function(_, opts)
    require("mini.statusline").setup(opts)
    set_highlights()
    require("transparent").keep("StatusLineTransparent", TRANSPARENT_GROUPS)
    create_redraw_autocmds()
    sync_statusline()

    vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
      group = vim.api.nvim_create_augroup("MiniStatuslineHideStarter", { clear = true }),
      callback = sync_statusline,
    })
  end,
}
