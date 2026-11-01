-- Reaplica el Tema de Omarchy en vivo. Dos disparadores: el hook
-- ~/.config/omarchy/hooks/theme-set (vía nvim --remote-expr) y un watcher
-- sobre ~/.local/state/omarchy/current. El ColorScheme resultante dispara la
-- transparencia de plugin/transparency.lua.
local OMARCHY_CURRENT = vim.fs.normalize(vim.env.HOME .. "/.local/state/omarchy/current")
local DEBOUNCE_MS = 120
local WATCHED = { ["theme.name"] = true, theme = true }

local pending

local function schedule_apply()
  if pending then
    pending:stop()
  end
  pending = vim.defer_fn(function()
    pending = nil
    require("omarchy.theme").apply()
  end, DEBOUNCE_MS)
end

-- Called by ~/.config/omarchy/hooks/theme-set via nvim --remote-expr
_G.OmarchyReloadTheme = function()
  schedule_apply()
  return "ok"
end

-- El hook busca sockets en $XDG_RUNTIME_DIR/nvim.<pid>.0
local function ensure_rpc_server()
  local sock = vim.fn.stdpath("run") .. "/nvim." .. vim.fn.getpid() .. ".0"
  if vim.tbl_contains(vim.fn.serverlist(), sock) then
    return
  end
  pcall(vim.fn.serverstart, sock)
end

---@param err string?
---@param filename string
local function on_change(err, filename)
  if not err and WATCHED[filename] then
    vim.schedule(schedule_apply)
  end
end

local function watch_omarchy_current()
  local handle = vim.uv.fs_stat(OMARCHY_CURRENT) and vim.uv.new_fs_event()
  if not handle then
    return
  end
  handle:start(OMARCHY_CURRENT, {}, on_change)
end

ensure_rpc_server()
watch_omarchy_current()
