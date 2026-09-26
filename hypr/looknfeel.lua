-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
	general = {
		border_size = 0,
		allow_tearing = true,
		resize_on_border = true,
		gaps_in = 4,
		gaps_out = 6,
	},
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
	decoration = {
		rounding = 12,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = false,
		},
	},
})

-- Override Omarchy default opacity rules — no transparency.
-- Window-rule syntax: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- o.window(".*", { tag = "-default-opacity" })
-- o.window(".*", { opacity = "1 1" })

-- A theme may ship its own looknfeel.lua (e.g. themes/industrial). Loaded last,
-- it replaces the geometry above only while that theme is current.
require("default.hypr.require_optional").module("omarchy.current.theme.looknfeel")
