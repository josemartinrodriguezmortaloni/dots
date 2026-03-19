local augroup = function(name) return vim.api.nvim_create_augroup(name, { clear = true }) end

vim.api.nvim_create_autocmd("TextYankPost", { group = augroup("HlYank"), callback = function() vim.hl.on_yank() end })

vim.api.nvim_create_autocmd(
  "FileType",
  { group = augroup("FormatOptions"), callback = function() vim.opt_local.formatoptions:remove({ "r", "o" }) end }
)

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("WrapSpell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("AutoCreateDir"),
  callback = function(ev)
    if not ev.match:match("^%w%w+:[\\/][\\/]") then vim.fn.mkdir(vim.fn.fnamemodify(ev.match, ":p:h"), "p") end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("LastLoc"),
  callback = function(ev)
    if not vim.b[ev.buf].last_loc and not vim.tbl_contains({ "gitcommit" }, vim.bo[ev.buf].filetype) then
      vim.b[ev.buf].last_loc = true
      local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
      if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("TrimWhitespace"),
  callback = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, cursor)
  end,
})
