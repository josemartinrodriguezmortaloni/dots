-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
	general = {
		allow_tearing = true,
		resize_on_border = true,

		border_size = 3,
		gaps_in = 5, -- mayor que el offset de la sombra
		gaps_out = 10,
	},
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
	decoration = {
		rounding = 0,
		blur = { enabled = false },
		shadow = {
			enabled = true,
			sharp = true,
			range = 2,
			offset = { 6, 6 },
			color = "rgba(1a1a1aee)",
		},
	},
})

-- Override Omarchy default opacity rules — no transparency.
-- Window-rule syntax: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
o.window(".*", { tag = "-default-opacity" })
o.window(".*", { opacity = "1 1" })

-- A theme may ship its own looknfeel.lua (e.g. themes/industrial). Loaded last,
-- it replaces the geometry above only while that theme is current.
require("default.hypr.require_optional").module("omarchy.current.theme.looknfeel")
