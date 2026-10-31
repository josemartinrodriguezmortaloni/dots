-- render-markdown: bloques de código, headings y tablas con bordes.
require("render-markdown").setup({
  file_types = { "markdown" },
  render_modes = { "n", "no", "c", "t", "i", "ic" },
  -- La línea del cursor muestra el markdown crudo solo en modo insert
  anti_conceal = { disabled_modes = { "n", "no", "c", "t" } },
  win_options = { concealcursor = { rendered = "nc" } },
  code = {
    sign = false,
    border = "thin",
    position = "right",
    width = "block",
    above = "▁",
    below = "▔",
    language_left = "█",
    language_right = "█",
    language_border = "▁",
    left_pad = 1,
    right_pad = 1,
  },
  heading = {
    sign = false,
    width = "block",
    left_pad = 1,
    right_pad = 0,
    position = "inline",
    icons = { "󰉫  ", "󰉬  ", "󰉭  ", "󰉮  ", "󰉯  ", "󰉰  " },
  },
  latex = { enabled = true, converter = { "utftex", "latex2text" }, inline = true, block = true },
  -- Profundidad por forma y relleno: lleno y hueco, círculo y cuadrado
  bullet = { icons = { "●", "○", "▪", "▫" } },
  pipe_table = { preset = "round", alignment_indicator = "─" },
})
