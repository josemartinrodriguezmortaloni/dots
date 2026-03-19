---@brief
---
--- https://docs.astral.sh/ruff/editors/
---
--- Ruff: An extremely fast Python linter and formatter, written in Rust.
---
--- Install with `pip install ruff` or `brew install ruff`

---@type vim.lsp.Config
return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  },
  settings = {
    -- https://docs.astral.sh/ruff/editors/settings/
    lineLength = 88,
    lint = {
      enable = true,
      preview = true,
    },
    format = {
      preview = true,
    },
  },
  -- Disable hover (basedpyright already provides it)
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
  end,
}
