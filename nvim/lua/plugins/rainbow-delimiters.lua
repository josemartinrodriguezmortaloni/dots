-- Tags de React en escala de grises (los grupos RainbowDelimiter* los define plain).
-- Config de ahmedelgabri/dotfiles@c12ff76 (config/nvim/plugin/treesitter.lua).

local MAX_FILESIZE = 1024 * 1024

---@param bufnr integer
---@return integer
local function file_size(bufnr)
  local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(bufnr))
  return stat and stat.size or 0
end

return {
  "HiPhish/rainbow-delimiters.nvim",
  ft = { "html", "javascriptreact", "jsx", "typescriptreact", "tsx" },
  main = "rainbow-delimiters.setup",
  opts = {
    enabled_when = function(bufnr)
      return file_size(bufnr) <= MAX_FILESIZE
    end,
    whitelist = { "html", "javascript", "jsx", "typescript", "tsx" },
    query = {
      javascript = "rainbow-tags-react",
      typescript = "rainbow-tags-react",
      tsx = "rainbow-tags-react",
      jsx = "rainbow-tags-react",
    },
  },
}
