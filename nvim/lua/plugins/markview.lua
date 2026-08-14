-- Markdown preview (from Work/dots/nvim).
-- Desactiva render-markdown del extra lang.markdown para evitar pelearse.
return {
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown", "mdx", "quarto", "rmd" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      {
        "<leader>m",
        "<cmd>Markview<CR>",
        desc = "Toggle Markview previews",
      },
    },
    opts = function()
      local presets = require("markview.presets").headings
      return {
        preview = { enable = true },
        headings = presets.simple,
        latex = {
          enable = true,
          blocks = {
            enable = true,
            hl = "MarkviewCode",
            pad_char = " ",
            pad_amount = 3,
            text = "  LaTeX ",
            text_hl = "MarkviewCodeInfo",
          },
          inlines = {
            enable = true,
            padding_left = " ",
            padding_right = " ",
            hl = "MarkviewInlineCode",
          },
          symbols = {
            enable = true,
            hl = "MarkviewComment",
          },
          texts = {
            enable = true,
          },
        },
        markdown = {
          enable = true,
          markdown_inline = {
            tags = {
              default = {
                hl = "MarkviewCodeInfo",
                padding_left = "",
                padding_left_hl = "MarkviewCodeFg",
                padding_right = "",
                padding_right_hl = "MarkviewCodeFg",
              },
              enable = true,
            },
          },
          tables = {
            enable = true,
            strict = false,
            block_decorator = true,
            use_virt_lines = false,
            parts = {
              top = { "╭", "─", "╮", "┬" },
              header = { "│", "│", "│" },
              separator = { "├", "─", "┤", "┼" },
              row = { "│", "│", "│" },
              bottom = { "╰", "─", "╯", "┴" },
              overlap = { "┝", "━", "┥", "┿" },
              align_left = "╼",
              align_right = "╾",
              align_center = { "╴", "╶" },
            },
            hl = {
              top = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
              header = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
              separator = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
              row = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
              bottom = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
              overlap = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
              align_left = "MarkviewTableAlignLeft",
              align_right = "MarkviewTableAlignRight",
              align_center = { "MarkviewTableAlignCenter", "MarkviewTableAlignCenter" },
            },
          },
        },
      }
    end,
  },
}
