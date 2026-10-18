-- render-markdown (del extra lang.markdown) con el estilo de
-- ahmedelgabri/dotfiles@c12ff76 (config/nvim/plugin/markdown.lua).
return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    file_types = { "markdown" },
    render_modes = { "n", "no", "c", "t", "i", "ic" },
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
    -- Profundidad por forma y relleno: lleno y hueco, círculo y cuadrado
    bullet = { icons = { "●", "○", "▪", "▫" } },
    pipe_table = { preset = "round", alignment_indicator = "─" },
  },
}
