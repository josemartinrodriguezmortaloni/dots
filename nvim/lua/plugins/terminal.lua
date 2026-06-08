return {
	{
		"NvChad/nvterm",
		lazy = true,
		opts = {
			terminals = {
				type_opts = {
					float = {
						relative = "editor",
						row = 0.15,
						col = 0.15,
						width = 0.7,
						height = 0.7,
						border = "rounded",
					},
					horizontal = { location = "rightbelow", split_ratio = 0.3 },
					vertical = { location = "rightbelow", split_ratio = 0.5 },
				},
			},
		},
		keys = {
			{
				"<A-i>",
				function()
					require("nvterm.terminal").toggle("float")
				end,
				mode = { "n", "t" },
				desc = "Terminal flotante",
			},
			{
				"<A-h>",
				function()
					require("nvterm.terminal").toggle("horizontal")
				end,
				mode = { "n", "t" },
				desc = "Terminal horizontal",
			},
			{
				"<A-v>",
				function()
					require("nvterm.terminal").toggle("vertical")
				end,
				mode = { "n", "t" },
				desc = "Terminal vertical",
			},
			{
				"<leader>tn",
				function()
					require("nvterm.terminal").new("horizontal")
				end,
				desc = "Nueva terminal",
			},
		},
	},
}
