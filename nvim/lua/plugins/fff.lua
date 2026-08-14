-- fff.nvim: file find + live grep (reemplaza snacks para esos flujos)
-- Repo: https://github.com/dmtrKovalenko/fff.nvim (aka dmtrKovalenko/fff)
return {
  {
    "dmtrKovalenko/fff.nvim",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false, -- el plugin se auto-inicializa
    opts = {
      -- debug = { enabled = true, show_scores = true },
    },
    keys = {
      {
        "<leader><space>",
        function()
          require("fff").find_files()
        end,
        desc = "Find Files (fff)",
      },
      {
        "<leader>/",
        function()
          require("fff").live_grep()
        end,
        desc = "Grep (fff)",
      },
      {
        "<leader>ff",
        function()
          require("fff").find_files()
        end,
        desc = "Find Files (fff)",
      },
      {
        "<leader>fF",
        function()
          require("fff").find_files_in_dir(vim.fn.getcwd())
        end,
        desc = "Find Files cwd (fff)",
      },
      {
        "<leader>sg",
        function()
          require("fff").live_grep()
        end,
        desc = "Grep (fff)",
      },
      {
        "<leader>sG",
        function()
          require("fff").live_grep({ cwd = vim.fn.getcwd() })
        end,
        desc = "Grep cwd (fff)",
      },
      {
        "<leader>sw",
        function()
          require("fff").live_grep_under_cursor()
        end,
        mode = { "n", "x" },
        desc = "Word / selection (fff)",
      },
      {
        "<leader>sW",
        function()
          require("fff").live_grep_under_cursor({ cwd = vim.fn.getcwd() })
        end,
        mode = { "n", "x" },
        desc = "Word / selection cwd (fff)",
      },
    },
  },

  -- Desactiva los mismos keymaps de snacks.picker para que no peleen
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader><space>", false },
      { "<leader>/", false },
      { "<leader>ff", false },
      { "<leader>fF", false },
      { "<leader>sg", false },
      { "<leader>sG", false },
      { "<leader>sw", false },
      { "<leader>sW", false },
    },
  },
}
