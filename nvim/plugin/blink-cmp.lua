-- Menú con íconos de mini.icons, labels de colorful-menu y bordes gruesos.

---@param label string
---@return string
local function path_category(label)
  return label:match("%.[^/]+$") and "file" or "directory"
end

---Ícono y highlight de mini.icons para el ítem; nil si mini.icons no está instalado
---@return string?, string?
local function mini_icon(ctx)
  local ok, MiniIcons = pcall(require, "mini.icons")
  if not ok then
    return nil
  end
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
  return hl or ctx.kind_hl
end

require("blink.cmp").setup({
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- See :h blink-cmp-config-keymap for defining your own keymap
  keymap = { preset = "super-tab" },

  completion = {
    menu = {
      border = "bold",
      draw = {
        -- colorful-menu colorea el label
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

  sources = { default = { "lsp", "path", "snippets", "buffer" } },

  -- Rust fuzzy matcher; el binario lo compila el build de init.lua
  fuzzy = { implementation = "rust" },
})
