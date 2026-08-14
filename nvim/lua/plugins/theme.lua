-- Omarchy keeps the active spec at current/theme/neovim.lua.
-- Load by absolute path: a relative symlink breaks when ~/.config/nvim
-- itself points into the dots repo.
local path = vim.fs.normalize("~/.config/omarchy/current/theme/neovim.lua")
if not vim.uv.fs_stat(path) then
  return {}
end
return dofile(path)
