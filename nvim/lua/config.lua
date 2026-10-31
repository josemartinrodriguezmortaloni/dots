-- Opciones propias que difieren de las de init.lua o que init.lua no define.
-- init.lua carga este archivo al final de la sección OPTIONS, así que estos
-- valores ganan.
local o = vim.o

o.number, o.relativenumber, o.showmode = true, true, false
o.scrolloff, o.sidescrolloff = 8, 8
o.pumheight = 12
o.timeoutlen = 400

-- Indent 4 con espacios; autocmds.lua lo baja a 2 en filetypes web y config
o.expandtab = true
o.tabstop, o.shiftwidth, o.softtabstop = 4, 4, 4
