-- nvim-treesitter (rama main) solo instala parsers y queries; el highlight y
-- la indentación se activan por buffer. Los folds usan 'foldexpr' (init.lua).
local PARSERS = {
  "bash",
  "c",
  "cpp",
  "css",
  "dockerfile",
  "html",
  "javascript",
  "json",
  "latex",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

-- No-op para los parsers ya instalados
require("nvim-treesitter").install(PARSERS)

---@param ev vim.api.keyset.create_autocmd.callback_args
local function attach(ev)
  -- pcall: falla en los filetypes sin parser instalado
  if not pcall(vim.treesitter.start, ev.buf) then
    return
  end
  vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_attach", { clear = true }),
  callback = attach,
})
