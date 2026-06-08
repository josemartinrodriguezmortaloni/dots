return {
	-- Statusline liviana del ecosistema mini.
	-- LazyVim trae lualine, pero está deshabilitado en disabled.lua, así que la
	-- statusline real la provee este módulo (como en la config vieja).
	{
		"nvim-mini/mini.statusline",
		event = "VeryLazy",
		opts = { use_icons = true },
	},

	-- Diff de git con overlay. Reemplaza la función de gitsigns (ver abajo).
	{
		"nvim-mini/mini.diff",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>go",
				function()
					require("mini.diff").toggle_overlay(0)
				end,
				desc = "Git: toggle overlay (mini.diff)",
			},
		},
	},

	-- mini.diff cubre los signos de git en el gutter; deshabilito gitsigns para
	-- no duplicarlos.
	{ "lewis6991/gitsigns.nvim", enabled = false },
}
