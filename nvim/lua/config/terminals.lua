-- Terminales dedicadas por rol (run / test / server) y resolución del comando
-- a partir del marcador de proyecto más cercano al archivo abierto.
-- Razón de cambio: adoptar un stack nuevo o cambiar el runner de uno existente.

local Terminal = require("toggleterm.terminal").Terminal

local M = {}

-- Gestor de paquetes JS: lo decide el lockfile presente, no una constante.
local LOCKFILES = {
  { "bun.lock", "bun" },
  { "bun.lockb", "bun" },
  { "pnpm-lock.yaml", "pnpm" },
  { "package-lock.json", "npm" },
}

local function package_manager(root)
  for _, entry in ipairs(LOCKFILES) do
    if vim.fn.filereadable(root .. "/" .. entry[1]) == 1 then
      return entry[2]
    end
  end
  return "npm"
end

local function js(script)
  return function(root, done)
    done(package_manager(root) .. " " .. script)
  end
end

-- Entrypoint de proyectos uv: memorizado por raíz durante la sesión.
local entrypoint = {}

local function scripts_block(root)
  local ok, lines = pcall(vim.fn.readfile, root .. "/pyproject.toml")
  if not ok then
    return ""
  end
  -- El "\n[" final garantiza que el patrón no codicioso cierre el último bloque.
  return (table.concat(lines, "\n") .. "\n["):match("%[project%.scripts%]\n(.-)\n%[") or ""
end

local function script_names(root)
  local names = {}
  for name in scripts_block(root):gmatch("([%w%-%_%.]+)%s*=") do
    names[#names + 1] = name
  end
  return names
end

local function remember(root, name, done)
  entrypoint[root] = name
  done("uv run " .. name)
end

local function choose_entrypoint(root, names, done)
  if #names == 1 then
    return remember(root, names[1], done)
  end
  vim.ui.select(names, { prompt = "Entrypoint uv" }, function(choice)
    if choice then
      remember(root, choice, done)
    end
  end)
end

local function python_run(root, done)
  if entrypoint[root] then
    return done("uv run " .. entrypoint[root])
  end
  local names = script_names(root)
  if #names == 0 then
    return done("uv run " .. vim.fn.shellescape(vim.fn.expand("%:p")))
  end
  choose_entrypoint(root, names, done)
end

-- El primer marcador que coincide gana: un repo Rust+Python resuelve como Rust.
local STACKS = {
  { marker = "Cargo.toml", run = "cargo run", test = "cargo test", server = "cargo run" },
  { marker = "pyproject.toml", run = python_run, test = "uv run pytest", server = python_run },
  { marker = "package.json", dep = "next", run = js("build"), test = js("test"), server = js("dev") },
  { marker = "package.json", dep = "@nestjs/core", run = js("build"), test = js("test"), server = js("start:dev") },
}

local function has_dep(root, dep)
  local ok, lines = pcall(vim.fn.readfile, root .. "/package.json")
  if not ok then
    return false
  end
  return table.concat(lines, ""):find('"' .. dep .. '"', 1, true) ~= nil
end

-- La raíz es el directorio del marcador más cercano hacia arriba, no la raíz git:
-- $HOME es un repo y dots/installer es un crate dentro de otro repo, así que
-- LazyVim.root() apunta afuera del proyecto en ambos casos.
local function start_dir()
  -- filereadable y no `== ""`: los buffers de scratch traen nombres tipo
  -- `ministarter://1/welcome`, que no son rutas pero tampoco están vacíos.
  local file = vim.api.nvim_buf_get_name(0)
  if vim.fn.filereadable(file) == 0 then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(file)
end

local function marker_root(marker, from)
  local found = vim.fs.find(marker, { upward = true, path = from })[1]
  if not found then
    return nil
  end
  -- `:p` fuerza ruta absoluta: vim.fs.find devuelve relativa si `from` no existe.
  return vim.fs.dirname(vim.fn.fnamemodify(found, ":p"))
end

local function accepts(stack, root)
  if not root then
    return false
  end
  if not stack.dep then
    return true
  end
  return has_dep(root, stack.dep)
end

local function detect(from)
  for _, stack in ipairs(STACKS) do
    local root = marker_root(stack.marker, from)
    if accepts(stack, root) then
      return stack, root
    end
  end
end

---Resuelve el comando del rol y lo entrega a `done(command, root)`.
function M.resolve(role, done)
  local from = start_dir()
  local stack, root = detect(from)
  if not stack then
    return vim.notify("terminals: sin marcador de proyecto desde " .. from, vim.log.levels.WARN)
  end
  local function deliver(command)
    done(command, root)
  end
  local command = stack[role]
  if type(command) == "function" then
    return command(root, deliver)
  end
  deliver(command)
end

-- El servidor corre dentro de tmux para sobrevivir al cierre de Neovim.
-- TMUX= limpia la variable heredada: sin eso tmux rechaza la sesión anidada.
local function plain(_, command)
  return command
end

local function tmux_session(root, command)
  local name = vim.fn.fnamemodify(root, ":t"):gsub("[^%w_-]", "-") .. "-server"
  return ("TMUX= tmux new-session -A -s %s %s"):format(vim.fn.shellescape(name), vim.fn.shellescape(command))
end

local ROLES = {
  run = { count = 2, wrap = plain },
  test = { count = 3, wrap = plain },
  server = { count = 4, wrap = tmux_session },
}

-- Las terminales de rol abren en modo normal y ceden <esc> al editor;
-- el shell de <A-i> conserva <esc> para los TUI que corren dentro.
local function on_open(term)
  vim.cmd("stopinsert")
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { buffer = term.bufnr })
  -- Cierre incondicional: la tecla del rol reejecuta cuando el proceso murió.
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = term.bufnr })
end

local active = {}

local function spawn(role, command, root)
  local spec = ROLES[role]
  active[role] = Terminal:new({
    cmd = spec.wrap(root, command),
    count = spec.count,
    dir = root,
    close_on_exit = false,
    on_open = on_open,
  })
  active[role]:open()
end

local function is_running(term)
  if not (term and term.job_id) then
    return false
  end
  return vim.fn.jobwait({ term.job_id }, 0)[1] == -1
end

---Muestra la terminal del rol si su proceso sigue vivo; si murió, la reejecuta.
function M.toggle(role)
  local term = active[role]
  if is_running(term) then
    return term:toggle()
  end
  -- shutdown libera el count en el registro de toggleterm: sin esto,
  -- Terminal:new devolvería la instancia vieja con el comando viejo.
  if term then
    term:shutdown()
  end
  M.resolve(role, function(command, root)
    spawn(role, command, root)
  end)
end

---Olvida el entrypoint uv memorizado para el proyecto actual.
function M.reset_entrypoint()
  local _, root = detect(start_dir())
  if not root then
    return
  end
  entrypoint[root] = nil
  vim.notify("terminals: entrypoint uv reiniciado en " .. root)
end

-- Los counts 1..4 pertenecen al shell y a los roles; las terminales sueltas
-- arrancan arriba de ese rango.
local free_count = 10

---Abre una terminal sin rol en el cwd de Neovim.
function M.new_shell()
  free_count = free_count + 1
  Terminal:new({ count = free_count, dir = vim.fn.getcwd() }):open()
end

return M
