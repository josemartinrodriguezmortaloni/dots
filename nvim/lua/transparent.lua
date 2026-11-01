-- Quita el fondo de grupos de highlight puntuales para que se vea el de la terminal.
-- plugin/transparency.lua la usa para el fondo general; otros plugins, para grupos puntuales.
local M = {}

---Quita el fondo de un grupo y conserva el resto de sus atributos
---@param name string
function M.clear_background(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  hl.bg, hl.ctermbg = nil, nil
  vim.api.nvim_set_hl(0, name, hl)
end

---Quita el fondo de `groups` ahora y en cada ColorScheme
---@param augroup string
---@param groups string[]
function M.keep(augroup, groups)
  local function apply()
    vim.tbl_map(M.clear_background, groups)
  end
  apply()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup(augroup, { clear = true }),
    callback = apply,
  })
end

return M
