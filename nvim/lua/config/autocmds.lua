-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function aug(name)
	return vim.api.nvim_create_augroup("custom-" .. name, { clear = true })
end

-- Limpiar espacios al final de línea al guardar (excepto markdown/diff)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = aug("trim-whitespace"),
	callback = function()
		if vim.bo.filetype == "markdown" or vim.bo.filetype == "diff" then
			return
		end
		local view = vim.fn.winsaveview()
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})

-- Indent de 2 espacios para lenguajes web/config (override del global a 4)
vim.api.nvim_create_autocmd("FileType", {
	group = aug("web-indent"),
	pattern = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"json",
		"jsonc",
		"html",
		"css",
		"scss",
		"yaml",
		"lua",
		"toml",
	},
	callback = function()
		vim.bo.tabstop, vim.bo.shiftwidth, vim.bo.softtabstop = 2, 2, 2
	end,
})
