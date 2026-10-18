-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
require("config.remote_clipboard").setup()

-- Python: ty (type checker, Astral) + ruff (lint/format). Ver lua/plugins/lsp.lua
vim.g.lazyvim_python_lsp = "ty"
vim.g.autoformat = true

local o = vim.o
o.background = require("omarchy.mode").background()
o.number, o.relativenumber, o.cursorline, o.signcolumn = true, true, true, "yes:2"
o.scrolloff, o.sidescrolloff, o.wrap, o.list = 8, 8, false, true
o.termguicolors, o.showmode, o.laststatus = true, false, 2
o.splitright, o.splitbelow = true, true
o.pumheight, o.winborder, o.pumborder = 12, "bold", "bold"

-- Estilo de ahmedelgabri/dotfiles@c12ff76 (config/nvim/init.lua)
o.cursorlineopt = "screenline,number"
o.smoothscroll, o.linebreak, o.breakindent, o.breakindentopt, o.showbreak = true, true, true, "list:-1", ""
o.guicursor = o.guicursor .. ",n-v-c:blinkon0,i-ci:ver25-Cursor/lCursor-blinkwait30-blinkoff100-blinkon100"
o.listchars = "multispace:⋅ ,lead:⋅,tab:  ,nbsp:░,extends:»,precedes:«,trail:␣"
o.fillchars = table.concat({
  "stl:⎼",
  "diff:╱",
  "msgsep:‾",
  "eob: ",
  "fold:─",
  "foldopen:▾",
  "foldsep: ",
  "foldinner: ",
  "foldclose:▸",
  "horiz:━",
  "horizup:┻",
  "horizdown:┳",
  "vert:┃",
  "vertleft:┫",
  "vertright:┣",
  "verthoriz:╋",
}, ",")
o.foldcolumn, o.foldlevel, o.foldtext = "1", 99, ""

-- Mensajes y cmdline en floats (UI2, API privada de nvim 0.12)
local has_ui2, ui2 = pcall(require, "vim._core.ui2")
if has_ui2 then
  o.cmdheight = 0
  ui2.enable({
    enable = true,
    msg = {
      targets = {
        [""] = "msg",
        empty = "cmd",
        bufwrite = "msg",
        confirm = "cmd",
        emsg = "pager",
        echo = "msg",
        echomsg = "msg",
        echoerr = "pager",
        completion = "cmd",
        list_cmd = "pager",
        lua_error = "pager",
        lua_print = "msg",
        progress = "pager",
        rpc_error = "pager",
        quickfix = "msg",
        search_cmd = "cmd",
        search_count = "cmd",
        shell_cmd = "pager",
        shell_err = "pager",
        shell_out = "pager",
        shell_ret = "msg",
        undo = "msg",
        verbose = "pager",
        wildlist = "cmd",
        wmsg = "msg",
        typed_cmd = "cmd",
      },
      cmd = { height = 0.5 },
      dialog = { height = 0.5 },
      msg = { height = 0.3, timeout = 5000 },
      pager = { height = 0.5 },
    },
  })
end
o.expandtab, o.smartindent = true, true -- indent 4; baja a 2 por filetype (autocmds)
o.tabstop, o.shiftwidth, o.softtabstop = 4, 4, 4
o.ignorecase, o.smartcase = true, true
o.undofile, o.swapfile, o.updatetime, o.timeoutlen = true, false, 250, 400
o.clipboard = "unnamedplus"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
