require("mini.ai").setup()
require("mini.pick").setup()
require("mini.extra").setup()
require("mini.surround").setup()

require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = true,
  },
})

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
  },
})

require("nvim-tree").setup({
  filters = { dotfiles = false },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = { enable = true, update_root = false },
  view = {
    width = 35,
    preserve_window_proportions = true,
  },
  renderer = {
    root_folder_label = false,
    indent_markers = { enable = true },
    icons = {
      web_devicons = { file = { enable = true }, folder = { enable = true } },
      git_placement = "after",
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = {
          unstaged = "●",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "✗",
          ignored = "◌",
        },
      },
    },
  },
})

require("which-key").setup({
  preset = "helix",
  icons = { mappings = false, rules = false, colors = false },
  win = { border = "single", padding = { 1, 1 } },
  spec = {
    { "<leader>b", group = "Buffer", icon = { icon = "󰓩", color = "blue" } },
    { "<leader>c", group = "Code", icon = { icon = "󰅱", color = "yellow" } },
    { "<leader>e", icon = { icon = "󰙅", color = "green" } },
    { "<leader>f", group = "Find", icon = { icon = "󰍉", color = "cyan" } },
    { "<leader>g", group = "Git", icon = { icon = "󰊤", color = "red" } },
    { "<leader>q", group = "Quit", icon = { icon = "󰗼", color = "red" } },
    { "<leader>s", group = "Split", icon = { icon = "󰃻", color = "blue" } },
    { "<leader>u", icon = { icon = "󰔚", color = "green" } },
    { "<leader>w", group = "Write", icon = { icon = "󰆓", color = "green" } },
  },
})

require("conform").setup({
  format_on_save = { lsp_format = "fallback", timeout_ms = 1000 },
  formatters_by_ft = {
    sh = { "shfmt" },
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    html = { "prettierd" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    c = { lsp_format = "prefer" },
    java = { lsp_format = "prefer" },
    ["_"] = { "prettierd" },
  },
  formatters = {
    stylua = { command = vim.fn.expand("~/.cargo/bin/stylua") },
    shfmt = { command = vim.fn.expand("~/.local/bin/shfmt") },
    prettierd = { command = vim.fn.expand("~/.bun/bin/prettierd") },
    ruff_format = { command = vim.fn.expand("~/.local/bin/ruff") },
    ruff_organize_imports = { command = vim.fn.expand("~/.local/bin/ruff") },
  },
})

require("markview").setup({})
