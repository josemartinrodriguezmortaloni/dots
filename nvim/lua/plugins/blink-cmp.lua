-- Menú con el estilo de ahmedelgabri/dotfiles@c12ff76 (config/nvim/plugin/completion.lua):
-- íconos de mini.icons, labels de colorful-menu y bordes gruesos.

---@param label string
---@return string
local function path_category(label)
  return label:match("%.[^/]+$") and "file" or "directory"
end

---Ícono y highlight de mini.icons para el ítem
---@return string?, string?
local function mini_icon(ctx)
  local MiniIcons = require("mini.icons")
  if ctx.item.source_name ~= "path" then
    return MiniIcons.get("lsp", ctx.kind)
  end
  return MiniIcons.get(path_category(ctx.item.label), ctx.item.label)
end

local function icon_text(ctx)
  return mini_icon(ctx) or ctx.kind_icon
end

local function icon_highlight(ctx)
  local _, hl = mini_icon(ctx)
  return hl
end

return {
  "saghen/blink.cmp",
  dependencies = {
    "saghen/blink.lib",
    -- optional: provides snippets for the snippet source
    "rafamadriz/friendly-snippets",
    "xzbdmw/colorful-menu.nvim",
  },
  build = function()
    -- build the fuzzy matcher, optionally add a timeout to `pwait(timeout_ms)`
    -- you can use `gb` in `:Lazy` to rebuild the plugin as needed
    require("blink.cmp").build():pwait()
  end,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = "super-tab" },

    completion = {
      menu = {
        border = "bold",
        draw = {
          -- colorful-menu colorea el label; sin el treesitter de LazyVim
          treesitter = {},
          padding = 1,
          gap = 2,
          columns = { { "kind_icon" }, { "label", "kind", gap = 2 } },
          components = {
            label = {
              width = { fill = true },
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
            kind_icon = { text = icon_text, highlight = icon_highlight },
            -- Solo `label` absorbe el espacio libre: `kind` queda en una columna fija
            kind = { width = { fill = false }, highlight = icon_highlight },
          },
        },
      },
      documentation = {
        auto_show = true,
        treesitter_highlighting = true,
        window = { border = "bold" },
      },
      ghost_text = { enabled = true },
    },

    signature = {
      enabled = true,
      window = { border = "bold", treesitter_highlighting = true },
    },

    -- (Default) list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = { default = { "lsp", "path", "snippets", "buffer" } },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    fuzzy = { implementation = "rust" },
  },
}
