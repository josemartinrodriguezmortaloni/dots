require("mini.git").setup()
require("mini.diff").setup({ view = { style = "sign", signs = { add = "+", change = "~", delete = "_" } } })

-- Diffview.nvim ─────────────────────────────────────────────────────────────────
local actions = require("diffview.actions")
require("diffview").setup({
  diff_binaries = false,
  enhanced_diff_hl = true,
  use_icons = true,
  icons = {
    folder_closed = "",
    folder_open = "",
  },
  signs = {
    fold_closed = "󰅂",
    fold_open = "󰅀",
    done = "✓",
  },
  view = {
    default = {
      layout = "diff2_horizontal",
      disable_diagnostics = true,
      winbar_info = false,
    },
    merge_tool = {
      layout = "diff3_horizontal",
    },
  },
  keymaps = {
    disable_defaults = false,
    view = {
      { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },
      { "n", "<tab>", actions.select_next_entry, { desc = "Next file diff" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Prev file diff" } },
      { "n", "]c", actions.select_next_entry, { desc = "Next change" } },
      { "n", "[c", actions.select_prev_entry, { desc = "Prev change" } },
      { "n", "o", actions.select_entry, { desc = "Open diff" } },
      { "n", "O", actions.select_entry, { desc = "Open diff (keep focus)" } },
      { "n", "gf", actions.goto_file, { desc = "Open file" } },
      { "n", "<leader>o", actions.toggle_files, { desc = "Toggle file panel" } },
      { "n", "x", actions.cycle_layout, { desc = "Cycle layout" } },
    },
    file_panel = {
      { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },
      { "n", "j", actions.next_entry, { desc = "Next file" } },
      { "n", "k", actions.prev_entry, { desc = "Prev file" } },
      { "n", "-", actions.scroll_view(-0.25), { desc = "Scroll up" } },
      { "n", "+", actions.scroll_view(0.25), { desc = "Scroll down" } },
      { "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage" } },
      { "n", "S", actions.stage_all, { desc = "Stage all" } },
      { "n", "U", actions.unstage_all, { desc = "Unstage all" } },
      { "n", "X", actions.restore_entry, { desc = "Restore file" } },
      { "n", "<tab>", actions.select_next_entry, { desc = "Next file" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Prev file" } },
      { "n", "x", actions.cycle_layout, { desc = "Cycle layout" } },
    },
    file_history_panel = {
      { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close" } },
      { "n", "j", actions.next_entry, { desc = "Next entry" } },
      { "n", "k", actions.prev_entry, { desc = "Prev entry" } },
      { "n", "<tab>", actions.select_next_entry, { desc = "Next entry" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Prev entry" } },
      { "n", "o", actions.select_entry, { desc = "Open entry" } },
      { "n", "O", actions.select_entry, { desc = "Open entry (keep focus)" } },
      { "n", "gf", actions.goto_file, { desc = "Open file" } },
      { "n", "L", actions.open_commit_log, { desc = "Open commit log" } },
      { "n", "X", actions.toggle_files, { desc = "Toggle files" } },
      { "n", "x", actions.cycle_layout, { desc = "Cycle layout" } },
    },
  },
})

-- Keymaps for Diffview
vim.keymap.set("n", "<leader>gd", "<Cmd>DiffviewOpen<CR>", { desc = "Diffview: Open" })
vim.keymap.set("n", "<leader>gD", "<Cmd>DiffviewOpen HEAD<CR>", { desc = "Diffview: Open HEAD" })
vim.keymap.set("n", "<leader>gF", "<Cmd>DiffviewFileHistory %<CR>", { desc = "Diffview: File history" })
vim.keymap.set("n", "<leader>gH", "<Cmd>DiffviewFileHistory<CR>", { desc = "Diffview: Commit history" })
