-- Make highlight groups transparent while preserving their other attributes
local function make_transparent(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if ok then
    hl.bg = nil
    vim.api.nvim_set_hl(0, name, hl)
  end
end

local groups = {
  -- transparent background
  "Normal",
  "NormalFloat",
  "FloatBorder",
  "Pmenu",
  "Terminal",
  "EndOfBuffer",
  "FoldColumn",
  "Folded",
  "SignColumn",
  "LineNr",
  "CursorLineNr",
  "NormalNC",
  "WhichKeyFloat",
  "TelescopeBorder",
  "TelescopeNormal",
  "TelescopePromptBorder",
  "TelescopePromptTitle",
  -- neotree
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeVertSplit",
  "NeoTreeWinSeparator",
  "NeoTreeEndOfBuffer",
  -- nvim-tree
  "NvimTreeNormal",
  "NvimTreeVertSplit",
  "NvimTreeEndOfBuffer",
  -- noice
  "NoiceCmdlinePopup",
  "NoiceCmdlinePopupBorder",
  "NoiceCmdlinePopupTitle",
  "NoicePopup",
  "NoicePopupBorder",
  "NoiceMini",
  -- snacks
  "SnacksNormal",
  "SnacksNormalNC",
  "SnacksWinBar",
  "SnacksPickerNormal",
  "SnacksPickerBorder",
  -- blink.cmp (also drives cmdline completion)
  "BlinkCmpMenu",
  "BlinkCmpMenuBorder",
  "BlinkCmpDoc",
  "BlinkCmpDocBorder",
  "BlinkCmpDocSeparator",
  "BlinkCmpSignatureHelp",
  "BlinkCmpSignatureHelpBorder",
  -- notify
  "NotifyINFOBody",
  "NotifyERRORBody",
  "NotifyWARNBody",
  "NotifyTRACEBody",
  "NotifyDEBUGBody",
  "NotifyINFOTitle",
  "NotifyERRORTitle",
  "NotifyWARNTitle",
  "NotifyTRACETitle",
  "NotifyDEBUGTitle",
  "NotifyINFOBorder",
  "NotifyERRORBorder",
  "NotifyWARNBorder",
  "NotifyTRACEBorder",
  "NotifyDEBUGBorder",
  "BufferLineTab",
  "NvimTreeEndOfBuffer",
}

local function apply()
  for _, name in ipairs(groups) do
    make_transparent(name)
  end
end

-- Reapply on every colorscheme change: loading a colorscheme repaints all
-- highlight groups, so a one-shot pass at startup is undone by the Omarchy
-- theme hot-reload or any later `:colorscheme`.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("transparency", { clear = true }),
  callback = apply,
})

apply()
