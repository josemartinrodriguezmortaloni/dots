-- Muestra inline `●` con el color de cada hex/rgb/rgba.
-- Las palabras TODO no van acá: esas siguen en todo-comments.

local SWATCH = "● "

---@param match string `#rgb`
---@return string
local function hex_short(match)
  local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
  return string.format("#%s%s%s%s%s%s", r, r, g, g, b, b)
end

---@param match string `rgb(r, g, b)`
---@return string
local function rgb_color(match)
  local red, green, blue = match:match("rgb%((%d+), ?(%d+), ?(%d+)%)")
  return string.format("#%02x%02x%02x", red, green, blue)
end

---@param alpha number?
---@return boolean
local function valid_alpha(alpha)
  return alpha ~= nil and alpha >= 0 and alpha <= 1
end

---Color de `rgba()` sobre fondo negro, o false si alpha está fuera de [0, 1]
---@param match string
---@return string|false
local function rgba_color(match)
  local red, green, blue, alpha = match:match("rgba%((%d+), ?(%d+), ?(%d+), ?(%d*%.?%d*)%)")
  alpha = tonumber(alpha)
  if not valid_alpha(alpha) then
    return false
  end
  return string.format("#%02x%02x%02x", red * alpha, green * alpha, blue * alpha)
end

local function extmark_opts_inline(_, _, data)
  return {
    virt_text = { { SWATCH, data.hl_group } },
    virt_text_pos = "inline",
    right_gravity = false,
  }
end

---@param pattern string
---@param to_hex fun(match: string): string|false
local function swatch_highlighter(pattern, to_hex)
  return {
    pattern = pattern,
    group = function(_, match)
      return require("mini.hipatterns").compute_hex_color_group(to_hex(match), "fg")
    end,
    extmark_opts = extmark_opts_inline,
  }
end

local hipatterns = require("mini.hipatterns")

hipatterns.setup({
  highlighters = {
    hex_color = hipatterns.gen_highlighter.hex_color({ style = "bg", inline_text = SWATCH }),
    hex_color_short = swatch_highlighter("#%x%x%x%f[%X]", hex_short),
    rgb_color = swatch_highlighter("rgb%(%d+, ?%d+, ?%d+%)", rgb_color),
    rgba_color = swatch_highlighter("rgba%(%d+, ?%d+, ?%d+, ?%d*%.?%d*%)", rgba_color),
  },
})
