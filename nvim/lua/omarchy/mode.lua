-- Modo (claro/oscuro) del Tema activo de Omarchy: fuente única de 'background'.
-- Mismo orden que omarchy-theme-color: clave `mode` de colors.toml, después el
-- marcador legacy `light.mode`.
local M = {}

local THEME_DIR = vim.env.HOME .. "/.local/state/omarchy/current/theme"

---@return string?
local function read_mode()
  local ok, lines = pcall(vim.fn.readfile, THEME_DIR .. "/colors.toml")
  if not ok then
    return nil
  end
  return vim
    .iter(lines)
    :map(function(line)
      return line:match('^%s*mode%s*=%s*"(%a+)"')
    end)
    :next()
end

---@return "light"|"dark"
function M.background()
  if read_mode() == "light" or vim.uv.fs_stat(THEME_DIR .. "/light.mode") then
    return "light"
  end
  return "dark"
end

return M
