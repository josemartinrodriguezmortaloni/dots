local au = require("utils.au")
local components = require("statusline.components")
local jj = require("statusline.jj")
local lsp = require("statusline.lsp")

local M = {}

-- Global: 'statusline' llama a M con %!v:lua.Statusline.<función>().
_G.Statusline = M

vim.o.laststatus = 2

-- Sin fondo: la línea se dibuja sobre el fondo del editor
require("transparent").keep("StatuslineTransparent", { "StatusLine", "StatusLineNC" })

---@return string
local function get_macro_status()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  end
  return string.format("%%#ErrorMsg#󰑊 Recording @%s%%*", recording_register)
end

---@return string
function M.render_active()
  if vim.bo.filetype == "help" or vim.bo.filetype == "man" then
    return "%#StatusLineNC#%f%*"
  end

  if vim.bo.filetype == "fzf" then
    return components.get_parts({
      "%#Statusline#",
      "fzf",
      "V: ctrl-v",
      "H: ctrl-s",
      "Tab: ctrl-t",
      "%*",
    })
  end

  if vim.bo.filetype == "oil" then
    return components.get_parts({
      jj.info() or components.git_info(),
      vim.fn.expand("%"),
    })
  end

  local line = components.get_parts({
    "%#Statusline#",
    jj.info() or components.git_info(),
    components.filepath(),
    components.readonly(),
    vim.b.minidiff_summary_string,
    components.git_conflicts(),
    "%=",
    get_macro_status(),
    components.word_count(),
    components.mode(),
    components.paste(),
    components.spell(),
    lsp.diagnostics(),
    vim.bo.busy > 0 and "◐ " or "",
    components.file_info(),
    components.rhs(),
    "%*",
  })

  return line
end

---@return string
function M.render_inactive()
  local line = "%#StatusLineNC#%f%* "

  return line
end

---------------------------------------------------------------------------------
-- Autocommands
---------------------------------------------------------------------------------
au.augroup("MyStatusLine", {
  {
    event = { "LspAttach", "LspDetach", "Progress" },
    pattern = "*",
    callback = function()
      vim.cmd.redrawstatus()
    end,
  },
  {
    event = "LspProgress",
    pattern = "*",
    callback = function(ev)
      local data = ev.data or {}
      local params = data.params or {}
      local value = params.value
      local token = params.token

      if type(value) ~= "table" or token == nil or value.kind == nil then
        return
      end

      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local client_name = client and client.name or "LSP"
      local chunks = {
        {
          string.format("[%s] %d%%: %s ", client_name, value.percentage or 100, value.title),
          "Comment",
        },
        { (value.message or "done"), "Comment" },
      }

      vim.api.nvim_echo(chunks, false, {
        id = "lsp." .. ev.data.client_id,
        kind = "progress",
        source = client_name,
        status = value.kind ~= "end" and "running" or "success",
      })
    end,
  },
  {
    event = "User",
    pattern = "MiniDiffUpdated",
    callback = components.format_diff_summary,
  },
  {
    event = { "BufEnter", "DirChanged", "FocusGained" },
    pattern = "*",
    callback = jj.update,
  },
  {
    event = { "RecordingEnter", "RecordingLeave" },
    pattern = "*",
    callback = function()
      -- On RecordingLeave, reg_recording() is still set until after the
      -- autocmd finishes, so defer the redraw to pick up the cleared state.
      vim.schedule(function()
        vim.cmd.redrawstatus()
      end)
    end,
  },

  -- https://www.reddit.com/r/neovim/comments/11215fn/comment/j8hs8vj/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  -- FWIW if you use vim.o.statuscolumn = '%{%StatusColFunc()%}' emphasis on the percent signs,
  -- then you can just use nvim_get_current_buf() and in the context of StatusColFunc that will be equal to get_buf(statusline_winid) trick.
  -- You can see :help stl-%{ but essentially in the context of %{} the buffer is changed to that of the window for which the status(line/col)
  -- is being drawn and the extra %} is so that the StatusColFunc can return things like %t and that gets evaluated to the filename
  {
    event = { "WinEnter", "BufEnter" },
    pattern = "*",
    callback = function()
      vim.wo.statusline = "%!v:lua.Statusline.render_active()"
    end,
  },
  {
    event = { "WinLeave", "BufLeave" },
    pattern = "*",
    callback = function()
      vim.wo.statusline = "%!v:lua.Statusline.render_inactive()"
    end,
  },
})
