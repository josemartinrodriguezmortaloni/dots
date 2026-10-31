-- Aplica el Tema activo de Omarchy. `omarchy theme set` escribe el spec en
-- ~/.local/state/omarchy/current/theme/neovim.lua con el formato de lazy.nvim:
-- entradas de plugin y una entrada "LazyVim/LazyVim" con opts.colorscheme.
-- Este módulo traduce ese spec a vim.pack. Lo usan plugin/theme.lua (arranque)
-- y plugin/omarchy-theme-hotreload.lua (cambio de tema en vivo).
local mode = require("omarchy.mode")

local M = {}

local CANDIDATES = {
  vim.fs.normalize(vim.env.HOME .. "/.local/state/omarchy/current/theme/neovim.lua"),
  vim.fs.normalize(vim.env.HOME .. "/.config/omarchy/current/theme/neovim.lua"),
}

local COLORSCHEME_ENTRY = "LazyVim/LazyVim"

---@param msg string
local function warn(msg)
  vim.notify(msg, vim.log.levels.WARN)
end

---@return string?
local function spec_path()
  return vim.iter(CANDIDATES):find(function(path)
    return vim.uv.fs_stat(path) ~= nil
  end)
end

---@param chunk function
---@return table?
local function run_chunk(chunk)
  local ok, spec = pcall(chunk)
  if ok and type(spec) == "table" then
    return spec
  end
  warn("Omarchy theme spec failed: " .. tostring(spec))
end

---@param path string
---@return table?
local function load_spec(path)
  local chunk, load_err = loadfile(path)
  if not chunk then
    warn("Omarchy theme spec unreadable: " .. tostring(load_err))
    return nil
  end
  return run_chunk(chunk)
end

---@param entry table
---@return boolean
local function is_plugin_entry(entry)
  return type(entry[1]) == "string" and entry[1] ~= COLORSCHEME_ENTRY
end

---@param entry table
---@return string
local function plugin_name(entry)
  return entry.name or vim.fs.basename(entry[1])
end

---Módulo Lua del plugin, inferido como lo hace lazy.nvim: "kanagawa.nvim" -> "kanagawa"
---@param entry table
---@return string
local function main_module(entry)
  return entry.main or (plugin_name(entry):gsub("%.nvim$", ""):gsub("%-nvim$", ""):gsub("^nvim%-", ""))
end

---@param name string
---@return boolean
local function is_active(name)
  return vim.iter(vim.pack.get(nil, { info = false })):any(function(plugin)
    return plugin.spec.name == name and plugin.active
  end)
end

-- Solo agrega lo que falta: vim.pack.add() con otro `src` para un nombre ya
-- instalado borra y reinstala el plugin (Omarchy 4 usa omacom/aether.nvim,
-- init.lua instala bjarneo/aether.nvim con el mismo nombre).
---@param entry table
local function ensure_added(entry)
  local name = plugin_name(entry)
  if is_active(name) then
    return
  end
  vim.pack.add({
    { src = "https://github.com/" .. entry[1], name = name, version = entry.branch },
  }, { confirm = false })
end

---@param modname string
---@param main string
---@return boolean
local function belongs(modname, main)
  return modname == main or vim.startswith(modname, main .. ".")
end

-- Descarga el código del tema para que setup() relea sus opts en un hot reload
---@param main string
local function unload(main)
  for modname in pairs(package.loaded) do
    if belongs(modname, main) then
      package.loaded[modname] = nil
    end
  end
end

---Misma precedencia que lazy.nvim: config() gana sobre opts
---@param entry table
---@param main string
local function setup_plugin(entry, main)
  if entry.config then
    entry.config(entry, entry.opts)
    return
  end
  if entry.opts then
    require(main).setup(entry.opts)
  end
end

---@param entry table
local function configure(entry)
  local main = main_module(entry)
  unload(main)
  setup_plugin(entry, main)
end

---@param spec table
---@return string?
local function colorscheme_of(spec)
  local entry = vim.iter(spec):find(function(e)
    return e[1] == COLORSCHEME_ENTRY
  end)
  return entry and vim.tbl_get(entry, "opts", "colorscheme")
end

---@param name string
local function set_colorscheme(name)
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    warn("Omarchy colorscheme failed: " .. tostring(err))
  end
end

---@param spec table
local function apply_spec(spec)
  local plugins = vim.iter(spec):filter(is_plugin_entry):totable()
  vim.tbl_map(ensure_added, plugins)
  vim.tbl_map(configure, plugins)

  vim.o.background = mode.background()
  local colorscheme = colorscheme_of(spec)
  if colorscheme then
    set_colorscheme(colorscheme)
  end
end

function M.apply()
  local path = spec_path()
  if not path then
    return
  end
  local spec = load_spec(path)
  if spec then
    apply_spec(spec)
  end
end

return M
