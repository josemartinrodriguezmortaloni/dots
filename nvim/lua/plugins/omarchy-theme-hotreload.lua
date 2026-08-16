return {
	{
		name = "theme-hotreload",
		dir = vim.fn.stdpath("config"),
		lazy = false,
		priority = 1000,
		config = function()
			local transparency_file = vim.fn.stdpath("config") .. "/plugin/after/transparency.lua"
			local omarchy_current = vim.fs.normalize(vim.env.HOME .. "/.local/state/omarchy/current")
			local debounce_ms = 120
			local pending

			local function load_theme_spec()
				package.loaded["plugins.theme"] = nil
				local ok, theme_spec = pcall(require, "plugins.theme")
				if ok and type(theme_spec) == "table" then
					return theme_spec
				end
			end

			local function patch_lazy_plugin(spec)
				local name = spec.name or spec[1]
				if type(name) ~= "string" or name == "LazyVim/LazyVim" then
					return
				end

				local Config = require("lazy.core.config")
				local plugin = Config.plugins[name]
				if not plugin and type(spec[1]) == "string" then
					local short = spec[1]:match("([^/]+)$")
					plugin = short and Config.plugins[short]
				end
				if not plugin then
					return
				end

				if spec.opts ~= nil then
					plugin.opts = spec.opts
				end
				if spec.config ~= nil then
					plugin.config = spec.config
				end
				if plugin._ then
					plugin._.cache = nil
				end
				return plugin, plugin.name
			end

			local function apply_theme()
				local theme_spec = load_theme_spec()
				if not theme_spec then
					return
				end

				local theme_plugin
				for _, spec in ipairs(theme_spec) do
					if spec[1] and spec[1] ~= "LazyVim/LazyVim" then
						theme_plugin = patch_lazy_plugin(spec)
						break
					end
				end

				vim.cmd("highlight clear")
				if vim.fn.exists("syntax_on") then
					vim.cmd("syntax reset")
				end
				vim.o.background = "dark"

				if theme_plugin then
					local plugin_dir = theme_plugin.dir .. "/lua"
					require("lazy.core.util").walkmods(plugin_dir, function(modname)
						package.loaded[modname] = nil
						package.preload[modname] = nil
					end)
				end

				for _, spec in ipairs(theme_spec) do
					if spec[1] == "LazyVim/LazyVim" and spec.opts and spec.opts.colorscheme then
						local colorscheme = spec.opts.colorscheme
						if theme_plugin and theme_plugin._.loaded then
							require("lazy.core.loader").reload(theme_plugin)
						else
							require("lazy.core.loader").colorscheme(colorscheme)
						end

						vim.defer_fn(function()
							pcall(vim.cmd.colorscheme, colorscheme)
							vim.cmd("redraw!")

							if vim.fn.filereadable(transparency_file) == 1 then
								vim.defer_fn(function()
									vim.cmd.source(transparency_file)
									vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
									vim.api.nvim_exec_autocmds("VimEnter", { modeline = false })
									vim.cmd("redraw!")
								end, 5)
							end
						end, 5)

						break
					end
				end
			end

			local function schedule_apply()
				if pending then
					pending:stop()
				end
				pending = vim.defer_fn(function()
					pending = nil
					apply_theme()
				end, debounce_ms)
			end

			-- Called by ~/.config/omarchy/hooks/theme-set via nvim --remote-expr
			_G.OmarchyReloadTheme = function()
				schedule_apply()
				return "ok"
			end

			local function ensure_rpc_server()
				local sock = vim.fn.stdpath("run") .. "/nvim." .. vim.fn.getpid() .. ".0"
				for _, existing in ipairs(vim.fn.serverlist()) do
					if existing == sock then
						return
					end
				end
				pcall(vim.fn.serverstart, sock)
			end

			local function watch_omarchy_current()
				if not vim.uv.fs_stat(omarchy_current) then
					return
				end
				local handle = vim.uv.new_fs_event()
				if not handle then
					return
				end
				handle:start(omarchy_current, {}, function(err, filename)
					if err then
						return
					end
					if filename == "theme.name" or filename == "theme" then
						vim.schedule(schedule_apply)
					end
				end)
			end

			ensure_rpc_server()
			watch_omarchy_current()

			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyReload",
				callback = schedule_apply,
			})
		end,
	},
}
