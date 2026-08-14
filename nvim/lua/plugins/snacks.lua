return {
  "folke/snacks.nvim",
  opts = {
    scroll = {
      enabled = false, -- Disable scrolling animations
    },
    dashboard = { enabled = false },
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
  },
}
