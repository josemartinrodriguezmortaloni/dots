return {
  "folke/snacks.nvim",
  opts = {
    scroll = {
      enabled = false, -- Disable scrolling animations
    },
    dashboard = { enabled = false },
    -- Mensajes por UI2 (lua/config/options.lua)
    notifier = { enabled = false },
    -- Estilo de ahmedelgabri: fold, número, signo
    statuscolumn = { left = { "fold" }, right = { "mark", "sign", "git" } },
    -- Solo el bloque actual, como blink.indent de ahmedelgabri
    indent = {
      indent = { enabled = false },
      scope = { char = "▎", hl = "Comment" },
      animate = { enabled = false },
    },
    picker = {
      sources = {
        projects = {
          -- carpetas “padre” donde viven tus repos
          dev = { "~/Work", "~/projects" },
          -- o projects sueltos, sin depender de un padre
          projects = {
            "~/Work/Sielc/sielcback/",
            "~/Work/Sielc/sielcfront/",
            "~/Work/Sielc/sielcmobile/",
            "~/Work/Enprendimiento/Proyectos/SimPlant/SimPlant-v3/SimPlantBack/",
            "~/Work/Enprendimiento/Proyectos/SimPlant/SimPlant-v3/SimPlantFront/",
            "~/Work/dots/",
            "~/.config/nvim",
          },
        },
      },
    },
    image = {
      enabled = true,
      doc = {
        inline = true,
        float = true,
        max_width = 120,
        max_height = 60,
        -- Oculta solo el código de los diagramas mermaid fuera del cursor
        conceal = function(lang)
          return lang == "mermaid"
        end,
      },
      math = { enabled = false }, -- render-markdown maneja el LaTeX
    },
  },
}
