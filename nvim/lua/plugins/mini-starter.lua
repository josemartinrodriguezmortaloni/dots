-- Start screen (estructura LazyVim extras/ui/mini-starter).
-- Header propio; paths/items los podés ajustar vos.
-- Frase al azar y recientes del cwd: ahmedelgabri/dotfiles@c12ff76 (lua/_/dashboard.lua).

local QUOTE_WIDTH = 60

---@param lines string[]
---@param word string
---@param width integer
local function append_word(lines, word, width)
  local candidate = vim.trim(lines[#lines] .. " " .. word)
  if vim.fn.strdisplaywidth(candidate) <= width then
    lines[#lines] = candidate
  else
    table.insert(lines, word)
  end
end

---Parte un texto en líneas de hasta `width` columnas, por palabras
---@param text string
---@param width integer
---@return string[]
local function wrap(text, width)
  local lines = { "" }
  for word in text:gmatch("%S+") do
    append_word(lines, word, width)
  end
  return lines
end

---@return string
local function quote_block()
  local lines = {}
  for _, line in ipairs(require("quotes").random()) do
    vim.list_extend(lines, wrap(line, QUOTE_WIDTH))
  end
  return table.concat(lines, "\n")
end

---Agrega `pad` a la sección de cada ítem para alinearla con las demás
---@param pad string
---@param section function
---@return function
local function padded(pad, section)
  return function()
    return vim.tbl_map(function(item)
      item.section = pad .. item.section
      return item
    end, section())
  end
end

return {
  -- disable snacks dashboard
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },

  -- enable mini.starter
  {
    "nvim-mini/mini.starter",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VimEnter",
    opts = function(_, opts)
      local logo = [[
    _______  ________  ________  ________   ________  ________
  //   /   \/        \/        \/    /   \ /        \/        \
 //        /         /         /         /_/       //         /
/         /        _/         /\        //         /         /
\__/_____/\________/\________/  \______/ \________/\__/__/__/
  ]]
      local pad = string.rep(" ", 22)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require("mini.starter")
      --stylua: ignore
      local items = {
        new_section("Find file",       LazyVim.pick(),                        "Telescope"),
        new_section("New file",        "ene | startinsert",                   "Built-in"),
        new_section("Recent files",    LazyVim.pick("oldfiles"),              "Telescope"),
        new_section("Find text",       LazyVim.pick("live_grep"),             "Telescope"),
        new_section("Config",          LazyVim.pick.config_files(),           "Config"),
        new_section("Restore session", [[lua require("persistence").load()]], "Session"),
        new_section("Lazy Extras",     "LazyExtras",                          "Config"),
        new_section("Lazy",            "Lazy",                                "Config"),
        new_section("Quit",            "qa",                                  "Built-in"),
        padded(pad, starter.sections.recent_files(5, true, false)),
      }

      -- Conservá items que haya inyectado snacks_picker (ej. Projects)
      opts.items = vim.list_extend(items, opts.items or {})
      opts.evaluate_single = true
      opts.header = logo .. "\n" .. quote_block()
      opts.content_hooks = {
        starter.gen_hook.adding_bullet(pad .. "░ ", false),
        starter.gen_hook.aligning("center", "center"),
      }
      return opts
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
