return {
  "nvim-mini/mini.statusline",
  version = false,
  init = function()
    -- Guardar laststatus y ocultar la barra en el start screen (sin args)
    vim.g.ministatusline_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    -- Nerd Font (como en la captura)
    local icons = {
      linux = "\u{f17c}",
      mac = "\u{f179}",
      win = "\u{f17a}",
      error = "\u{f057}",
      warn = "\u{f071}",
      added = "\u{f457}",
      changed = "\u{f459}",
      removed = "\u{f458}",
    }

    local function section_os()
      local sys = vim.uv.os_uname().sysname
      if sys == "Linux" then
        return icons.linux
      end
      if sys == "Darwin" then
        return icons.mac
      end
      if sys == "Windows_NT" then
        return icons.win
      end
      return sys
    end

    local function section_encoding()
      local enc = vim.bo.fileencoding
      if enc == nil or enc == "" then
        enc = vim.o.encoding
      end
      return enc
    end

    -- Resumen de gitsigns con un icono por tipo de cambio
    local function section_diff()
      if MiniStatusline.is_truncated(75) then
        return ""
      end
      local summary = vim.b.gitsigns_status_dict
      if not summary then
        return ""
      end
      local parts = {}
      for _, item in ipairs({
        { icons.added, summary.added },
        { icons.changed, summary.changed },
        { icons.removed, summary.removed },
      }) do
        local n = item[2] or 0
        if n > 0 then
          parts[#parts + 1] = item[1] .. n
        end
      end
      return table.concat(parts, " ")
    end

    -- Solo errores y warnings
    local function section_diagnostics()
      if not vim.diagnostic.is_enabled({ bufnr = 0 }) then
        return ""
      end
      local count = vim.diagnostic.count(0)
      if not count then
        return ""
      end
      local parts = {}
      local errors = count[vim.diagnostic.severity.ERROR] or 0
      local warns = count[vim.diagnostic.severity.WARN] or 0
      if errors > 0 then
        parts[#parts + 1] = icons.error .. errors
      end
      if warns > 0 then
        parts[#parts + 1] = icons.warn .. warns
      end
      return table.concat(parts, " ")
    end

    local function active()
      if vim.bo.filetype == "ministarter" then
        return ""
      end

      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = math.huge })
      mode = mode:sub(1, 1)

      local filename = "%t%m%r"
      local git = MiniStatusline.section_git({ trunc_width = 75 })
      local diff = section_diff()
      local diagnostics = section_diagnostics()

      local filetype = MiniStatusline.section_fileinfo({ trunc_width = math.huge })
      local os_name = section_os()
      -- local encoding = section_encoding()
      local location = "%l:%v  %p%%"

      return MiniStatusline.combine_groups({
        -- { hl = "MiniStatuslineFilename", strings = { mode } },
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { filename, git, diff, diagnostics } },
        "%<",
        "%=",
        { hl = "MiniStatuslineFileinfo", strings = { filetype, os_name } },
        { hl = mode_hl, strings = { location } },
      })
    end

    return {
      content = {
        active = active,
        inactive = function()
          if vim.bo.filetype == "ministarter" then
            return ""
          end
          return "%#MiniStatuslineInactive#%t%="
        end,
      },
      use_icons = true,
    }
  end,
  config = function(_, opts)
    require("mini.statusline").setup(opts)

    local hide_ft = {
      ministarter = true,
      dashboard = true,
      alpha = true,
      snacks_dashboard = true,
    }

    local function sync_statusline()
      if hide_ft[vim.bo.filetype] then
        vim.b.ministatusline_disable = true
        vim.o.laststatus = 0
      else
        vim.o.laststatus = vim.g.ministatusline_laststatus or 3
      end
    end

    -- Si arrancamos en starter, no restaurar aún
    if not hide_ft[vim.bo.filetype] and vim.fn.argc(-1) > 0 then
      vim.o.laststatus = vim.g.ministatusline_laststatus or 3
    end
    sync_statusline()

    vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
      group = vim.api.nvim_create_augroup("MiniStatuslineHideStarter", { clear = true }),
      callback = sync_statusline,
    })
  end,
}
