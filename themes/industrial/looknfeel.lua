-- Industrial window geometry, DESIGN.md §3.5: a 1 px stroke, square corners,
-- and depth drawn with borders only, so no shadow and no blur. The border
-- colours come from hyprland.lua, which Omarchy generates from colors.toml.
--
-- hypr/looknfeel.lua requires this module last, so it replaces the user's
-- geometry only while Industrial is the current theme.
hl.config({
  general = {
    border_size = 1,
  },

  decoration = {
    rounding = 0,
    shadow = {
      enabled = false,
    },
    blur = {
      enabled = false,
    },
  },
})
