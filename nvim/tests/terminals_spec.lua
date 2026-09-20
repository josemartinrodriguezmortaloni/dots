-- Regresión: la raíz del proyecto se resolvía a "." cuando el buffer activo
-- era un scratch con nombre tipo URI (mini.starter), lo que producía sesiones
-- de tmux llamadas "--server" compartidas entre todos los proyectos.
-- PlenaryBustedFile corre cada spec en una instancia nueva donde lazy.nvim no
-- terminó de inicializarse, así que el plugin entra por runtimepath y no por
-- require("lazy").load.
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/toggleterm.nvim")
local terminals = require("config.terminals")

local function fixture()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir .. "/src", "p")
  vim.fn.writefile({ '{ "dependencies": { "next": "15.0.0" } }' }, dir .. "/package.json")
  vim.fn.writefile({ "lockfileVersion: '9.0'" }, dir .. "/pnpm-lock.yaml")
  vim.fn.writefile({ "export default 1" }, dir .. "/src/page.tsx")
  return dir
end

local function resolved(role)
  local got = {}
  terminals.resolve(role, function(command, root)
    got.command, got.root = command, root
  end)
  return got
end

describe("config.terminals", function()
  local dir

  before_each(function()
    dir = fixture()
  end)

  it("cae al cwd cuando el buffer activo no es un archivo", function()
    vim.cmd("cd " .. dir)
    vim.cmd("enew")
    vim.api.nvim_buf_set_name(0, "ministarter://1/welcome")
    local got = resolved("server")
    assert.are.equal("pnpm dev", got.command)
    assert.are.equal(vim.fn.resolve(dir), vim.fn.resolve(got.root))
  end)

  it("resuelve la raíz desde el archivo abierto, no desde el cwd", function()
    vim.cmd("cd /")
    vim.cmd("edit " .. dir .. "/src/page.tsx")
    local got = resolved("server")
    assert.are.equal("pnpm dev", got.command)
    assert.are.equal(vim.fn.resolve(dir), vim.fn.resolve(got.root))
  end)

  it("nunca devuelve una raíz relativa", function()
    vim.cmd("cd " .. dir)
    vim.cmd("enew")
    vim.api.nvim_buf_set_name(0, "oil:///directorio/inexistente")
    assert.is_truthy(resolved("run").root:match("^/"))
  end)
end)
