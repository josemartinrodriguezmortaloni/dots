require("vitesse").setup({
  comment_italics = true,
  transparent_background = false,
  transparent_float_background = true, -- aka pum(popup menu) background
  reverse_visual = false,
  dim_nc = false,
  cmp_cmdline_disable_search_highlight_group = false, -- disable search highlight group for cmp item
  -- if `transparent_float_background` false, make telescope border color same as float background
  telescope_border_follow_float_background = false,
  -- similar to above, but for lspsaga
  lspsaga_border_follow_float_background = false,
  -- diagnostic virtual text background, like error lens
  diagnostic_virtual_text_background = false,

  -- override the `lua/vitesse/palette.lua`, go to file see fields
  colors = {},
  themes = {},
})
vim.cmd("colorscheme vitesse")

local devicons = (function()
  local ok, mod = pcall(require, "nvim-web-devicons")
  if ok then
    mod.setup()
    return mod
  end
end)()

-- Statusline ──────────────────────────────────────────────────────────────────

vim.api.nvim_set_hl(0, "StatusLineFiletype", { fg = "#101010", bg = "#A0A0A0" })

local function get_filename()
  local name = vim.fn.expand("%:t")
  return name ~= "" and name or "[Sin nombre]"
end

local function get_file_icon(filetype)
  if not devicons then return "", "StatusLineFiletype" end
  local icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
  local hl_name = "StatusLineFiletype"
  local icon_color = vim.api.nvim_get_hl(0, { name = icon_hl or "", link = false })
  if icon_color.fg then
    vim.api.nvim_set_hl(0, "StatusLineIcon", { fg = icon_color.fg, bg = "#A0A0A0" })
    hl_name = "StatusLineIcon"
  end
  return icon or "", hl_name
end

local statusline = require("mini.statusline")
statusline.setup({
  use_icons = true,
  content = {
    active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local git = statusline.section_git({ trunc_width = 40 })
      local filetype = vim.bo.filetype
      local ft_icon, ft_icon_hl = get_file_icon(filetype)
      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "StatusLine", strings = { git, get_filename() } },
        "%=",
        { hl = ft_icon_hl, strings = { " " .. ft_icon .. " " } },
        { hl = "StatusLineFiletype", strings = { filetype .. " " } },
      })
    end,
  },
})

-- Tabline ─────────────────────────────────────────────────────────────────────

vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#101010", bg = "#FFC799", bold = true })
vim.api.nvim_set_hl(0, "TabLine", { fg = "#7E7E7E", bg = "NONE" })

local function get_buf_icon(name)
  if not devicons then return "" end
  return (devicons.get_icon(name, nil, { default = true }) or "") .. " "
end

local function format_buf_entry(bufnr, is_current)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  if name == "" then name = "[Sin nombre]" end
  local icon = get_buf_icon(name)
  local modified = vim.bo[bufnr].modified and " ●" or ""
  local hl = is_current and "%#TabLineSel#" or "%#TabLine#"
  return hl .. " " .. icon .. name .. modified .. " "
end

function _G.custom_tabline()
  local bufs = vim.tbl_filter(
    function(b) return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted end,
    vim.api.nvim_list_bufs()
  )
  local current = vim.api.nvim_get_current_buf()
  local parts = {}
  for _, b in ipairs(bufs) do
    table.insert(parts, format_buf_entry(b, b == current))
  end
  return table.concat(parts) .. "%#TabLineFill#"
end

local function listed_buf_count()
  return #vim.tbl_filter(
    function(b) return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and vim.api.nvim_buf_get_name(b) ~= "" end,
    vim.api.nvim_list_bufs()
  )
end

local function update_tabline_visibility() vim.o.showtabline = listed_buf_count() > 0 and 2 or 0 end

vim.o.tabline = "%!v:lua.custom_tabline()"
update_tabline_visibility()

vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufWipeout", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("TablineVisibility", { clear = true }),
  callback = update_tabline_visibility,
})
