-- Los servidores vienen de los extras de LazyVim (lang.python -> ty + ruff,
-- lang.rust -> rustaceanvim, lang.clangd -> clangd); el de Python lo elige
-- vim.g.lazyvim_python_lsp en lua/config/options.lua.
-- El ajuste fino de cada servidor vive en lua/servers/<nombre>.lua.
-- Diagnósticos y hover: estilo de ahmedelgabri/dotfiles@c12ff76
-- (config/nvim/plugin/diagnostics.lua y plugin/lsp.lua).

local severity = vim.diagnostic.severity

local SEVERITY_ICONS = {
  [severity.ERROR] = "×",
  [severity.WARN] = "⚐",
  [severity.INFO] = "𝒾",
  [severity.HINT] = "•",
}

local SEVERITY_HL = {
  [severity.ERROR] = "DiagnosticError",
  [severity.WARN] = "DiagnosticWarn",
  [severity.INFO] = "DiagnosticInfo",
  [severity.HINT] = "DiagnosticHint",
}

local CLEAN_SOURCE_NAMES = {
  ["Lua Diagnostics."] = "lua",
  ["Lua Syntax Check."] = "lua",
}

-- El ícono del texto virtual va sin el fondo que le pone el tema
local TRANSPARENT_GROUPS = {
  "DiagnosticVirtualTextError",
  "DiagnosticVirtualTextWarn",
  "DiagnosticVirtualTextInfo",
  "DiagnosticVirtualTextHint",
}

local HOVER_LIMITS = { max_width = 80, max_height = 20 }

---Borde grueso con highlight propio
---@param hl string
---@return table
local function bold_border(hl)
  return vim.tbl_map(function(char)
    return { char, hl }
  end, { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" })
end

---Severidad más alta (número más bajo) en la línea del cursor
---@param bufnr integer
---@return integer
local function cursor_max_severity(bufnr)
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local severities = vim.tbl_map(function(d)
    return d.severity
  end, vim.diagnostic.get(bufnr, { lnum = lnum }))
  return math.min(severity.HINT, unpack(severities))
end

-- El borde del float toma el color de la severidad más alta de la línea
local function color_float_border()
  local open_float = vim.diagnostic.open_float
  vim.diagnostic.open_float = function(bufnr, opts)
    opts = opts or {}
    opts.border = bold_border(SEVERITY_HL[cursor_max_severity(opts.bufnr or 0)])
    return open_float(bufnr, opts)
  end
end

local function limit_hover_size()
  local open_floating_preview = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
    if opts and opts.focus_id == "textDocument/hover" then
      opts = vim.tbl_extend("force", opts, HOVER_LIMITS)
    end
    return open_floating_preview(contents, syntax, opts)
  end
end

---@param counts table<integer, integer>
---@param sev integer
---@return string?
local function status_part(counts, sev)
  local count = counts[sev] or 0
  if count == 0 then
    return nil
  end
  return string.format(
    "%%#%s#%s%d%%*",
    (SEVERITY_HL[sev]:gsub("^Diagnostic", "DiagnosticSign")),
    SEVERITY_ICONS[sev],
    count
  )
end

---@param counts table<integer, integer>
---@return string
local function status_format(counts)
  return vim
    .iter({ severity.ERROR, severity.WARN, severity.INFO, severity.HINT })
    :map(function(sev)
      return status_part(counts, sev)
    end)
    :join(" ")
end

---@param diag vim.Diagnostic
---@return string
local function source_name(diag)
  return CLEAN_SOURCE_NAMES[diag.source] or diag.source or ""
end

---@param diag vim.Diagnostic
---@return string
local function diag_source(diag)
  if not diag.code then
    return source_name(diag)
  end
  return source_name(diag) .. " -> " .. diag.code
end

return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      require("servers")
      color_float_border()
      limit_hover_size()
      require("transparent").keep("DiagnosticTransparent", TRANSPARENT_GROUPS)
    end,
    opts = {
      diagnostics = {
        severity_sort = true,
        signs = false,
        jump = {
          on_jump = function(diagnostic, bufnr)
            if diagnostic then
              vim.diagnostic.open_float(bufnr, { scope = "cursor" })
            end
          end,
        },
        status = { format = status_format },
        virtual_text = {
          spacing = 0,
          prefix = function(diag, _, total)
            local icon = SEVERITY_ICONS[diag.severity]
            return total > 1 and " " .. icon or icon
          end,
          format = function()
            return ""
          end,
        },
        float = {
          source = false,
          header = "",
          suffix = "",
          prefix = function(diag)
            return string.format(" %s ", SEVERITY_ICONS[diag.severity]), SEVERITY_HL[diag.severity]
          end,
          format = function(diag)
            return string.format("[%s] %s", diag_source(diag), diag.message)
          end,
        },
      },
    },
  },
}
