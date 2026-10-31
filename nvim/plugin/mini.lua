require("mini.pairs").setup()

-- fast surround editing
require("mini.surround").setup({
  mappings = {
    add = "sa", -- Add surrounding in Normal and Visual modes
    delete = "sd", -- Delete surrounding
    find = "", -- Find surrounding (to the right)
    find_left = "", -- Find surrounding (to the left)
    highlight = "", -- Highlight surrounding
    replace = "sr", -- Replace surrounding
  },
  n_lines = 30,
})
