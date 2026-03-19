vim.pack.add({
  { src = "https://github.com/mbbill/undotree" },
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/nvim-mini/mini.icons" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("*") },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/OXY2DEV/markview.nvim.git" },
  { src = "https://github.com/sindrets/diffview.nvim" },
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  { src = "https://github.com/datsfilipe/vesper.nvim" },
})

require("plugins.editor")
require("plugins.ui")
require("plugins.git")
require("plugins.treesitter")
