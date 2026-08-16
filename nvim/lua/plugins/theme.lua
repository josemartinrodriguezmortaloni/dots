-- Loads the Neovim spec of the currently active Omarchy theme.
-- Source of truth: ~/.local/state/omarchy/current/theme/neovim.lua
-- (written by `omarchy theme set`). A real file instead of a symlink so the
-- dots repo stays portable; hot-reload lives in omarchy-theme-hotreload.lua.

local candidates = {
  vim.fs.normalize(vim.env.HOME .. "/.local/state/omarchy/current/theme/neovim.lua"),
  vim.fs.normalize(vim.env.HOME .. "/.config/omarchy/current/theme/neovim.lua"),
}

for _, path in ipairs(candidates) do
  if vim.uv.fs_stat(path) then
    local chunk, load_err = loadfile(path)
    if chunk then
      local ok, spec = pcall(chunk)
      if ok and type(spec) == "table" then
        return spec
      end
      vim.notify("Omarchy theme spec failed: " .. tostring(spec), vim.log.levels.WARN)
    else
      vim.notify("Omarchy theme spec unreadable: " .. tostring(load_err), vim.log.levels.WARN)
    end
    break
  end
end

return {}
