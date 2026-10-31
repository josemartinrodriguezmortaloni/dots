-- Binarios de conform y de los servidores de lua/servers/init.lua que el
-- sistema no trae (lua-language-server, ruff, clangd y rust-analyzer vienen
-- de pacman/cargo).
local ENSURE_INSTALLED = {
  -- formatters
  "stylua",
  "prettier",
  "clang-format",
  -- servidores
  "ty",
  "gopls",
  "json-lsp",
  "typescript-language-server",
  "bash-language-server",
  "dockerfile-language-server",
  "emmet-ls",
  "yaml-language-server",
  "tailwindcss-language-server",
}

-- mason.setup() agrega su bin/ al PATH: los servidores lo encuentran ahí
require("mason").setup()

local registry = require("mason-registry")

---@param name string
local function ensure(name)
  if registry.is_installed(name) then
    return
  end
  registry.get_package(name):install()
end

registry.refresh(function()
  vim.tbl_map(ensure, ENSURE_INSTALLED)
end)
