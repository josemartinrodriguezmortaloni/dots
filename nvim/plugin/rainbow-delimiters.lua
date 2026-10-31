local MAX_FILESIZE = 1024 * 1024

---@param bufnr integer
---@return integer
local function file_size(bufnr)
  local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(bufnr))
  return stat and stat.size or 0
end

require("rainbow-delimiters.setup").setup({
  condition = function(bufnr)
    return file_size(bufnr) <= MAX_FILESIZE
  end,
  whitelist = { "html", "javascript", "typescript", "tsx" },
  query = {
    javascript = "rainbow-tags-react",
    tsx = "rainbow-tags-react",
  },
})
