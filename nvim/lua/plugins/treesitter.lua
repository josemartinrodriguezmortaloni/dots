return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"python",
				"typescript",
				"tsx",
				"javascript",
				"rust",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"json",
				"toml",
				"yaml",
				"markdown",
				"markdown_inline",
				"bash",
				"html",
				"css",
				"sql",
				"dockerfile",
				"regex",
			})
		end,
	},
}
