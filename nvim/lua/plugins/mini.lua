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
}
