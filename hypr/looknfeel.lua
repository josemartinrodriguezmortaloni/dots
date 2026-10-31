-- Change the default Omarchy look'n'feel.
-- Border colours come from the current theme's hyprland.lua, which Omarchy
-- generates from hyprland_active_border and hyprland_inactive_border in
-- colors.toml.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 10,
		border_size = 1,
		resize_on_border = true,
	},
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
	decoration = {
		rounding = 12,
		rounding_power = 2.4,

		blur = {
			enabled = false,
			size = 12,
			passes = 4,
			new_optimizations = true,
			xray = false,
			ignore_opacity = false,
			popups = true,
		},

		shadow = {
			enabled = true,
			range = 28,
			render_power = 3,
			color = "rgba(00000066)",
			color_inactive = "rgba(00000025)",
		},

		fullscreen_opacity = 1.0,

		dim_inactive = true,
		dim_strength = 0.08,
	},
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.25, 1.0 }, { 0.5, 1.0 } } })
hl.curve("snappy", { type = "bezier", points = { { 0.4, 0.0 }, { 0.2, 1.0 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "overshot", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "snappy", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "snappy" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 12, bezier = "smooth", style = "once" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "overshot", style = "slidefadevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "smooth", style = "slidevert" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "smooth", style = "slidefade" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 3, bezier = "smooth" })

hl.config({
	dwindle = {
		preserve_split = true,
		smart_split = false,
		smart_resizing = true,
	},

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		animate_manual_resizes = true,
		animate_mouse_windowdragging = true,
		focus_on_activate = true,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},
})

-- Hornet pet: only the PNG is visible, with no background, blur or shadow.
hl.layer_rule({ match = { namespace = "qs-pet" }, blur = false, ignore_alpha = 0.01, no_anim = true, xray = true })

-- Zathura as a centered floating panel.
o.window("^(org.pwmt.zathura)$", {
	float = true,
	center = true,
	size = { 1100, 750 },
	border_size = 0,
})

-- A theme may ship its own looknfeel.lua (e.g. themes/industrial). Loaded last,
-- its rules exist only while that theme is current.
require("default.hypr.require_optional").module("omarchy.current.theme.looknfeel")
