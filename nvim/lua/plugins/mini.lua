return {
  -- Provee la rama de git a la statusline. No agrega signos al gutter.
  {
    "nvim-mini/mini-git",
    event = "VeryLazy",
    config = function()
      require("mini.git").setup()
      -- Mostrar solo el nombre de la rama (sin flags de estado del archivo).
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniGitUpdated",
        callback = function(data)
          local s = vim.b[data.buf].minigit_summary
          vim.b[data.buf].minigit_summary_string = s and s.head_name or ""
        end,
      })
    end,
  },

  -- Diff de git con overlay (signos en el gutter).
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

  -- gitsigns deshabilitado: mini.diff cubre el gutter, mini.git la rama.
  { "lewis6991/gitsigns.nvim", enabled = false },
  {
    "nvim-mini/mini.starter",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VimEnter",
    opts = function()
      local new_section = function(name, action, section)
        return { name = name, action = action, section = section }
      end

      local starter = require("mini.starter")

      -- `aligning` desplaza el bloque entero con un único padding izquierdo,
      -- así que las líneas cortas (el header) quedan pegadas a la izquierda.
      -- Este hook centra el header respecto a la línea más ancha del menú.
      local center_header = function(content)
        local max_width = 0
        for _, line in ipairs(starter.content_to_lines(content)) do
          max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
        end
        for _, line in ipairs(content) do
          for _, unit in ipairs(line) do
            if unit.type == "header" then
              local width = vim.fn.strdisplaywidth(unit.string)
              local left = math.max(math.floor((max_width - width) / 2), 0)
              unit.string = string.rep(" ", left) .. unit.string
            end
          end
        end
        return content
      end
    --stylua: ignore
    local config = {
      evaluate_single = true,
      header = "Welcome",
      items = {
        new_section("Find file",       LazyVim.pick(),                        "Telescope"),
        new_section("New file",        "ene | startinsert",                   "Built-in"),
        new_section("Recent files",    LazyVim.pick("oldfiles"),              "Telescope"),
        new_section("Find text",       LazyVim.pick("live_grep"),             "Telescope"),
        new_section("Config",          LazyVim.pick.config_files(),           "Config"),
        new_section("Restore session", [[lua require("persistence").load()]], "Session"),
        new_section("Lazy Extras",     "LazyExtras",                          "Config"),
        new_section("Lazy",            "Lazy",                                "Config"),
        new_section("Quit",            "qa",                                  "Built-in"),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet("░ ", false),
        center_header,
        starter.gen_hook.aligning("center", "center"),
      },
    }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      local starter = require("mini.starter")
      starter.setup(config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function(ev)
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local pad_footer = string.rep(" ", 8)
          starter.config.footer = pad_footer .. "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          -- INFO: based on @nvim-mini's recommendation (thanks a lot!!!)
          if vim.bo[ev.buf].filetype == "ministarter" then
            pcall(starter.refresh)
          end
        end,
      })
    end,
  },
}
