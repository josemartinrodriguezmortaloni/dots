-- Industrial only: frosted glass on the bar and the menu card.
-- hypr/looknfeel.lua requires this module last, so the rules exist only while
-- Industrial is the current theme. Hyprland blurs only the pixels whose alpha
-- is above ignore_alpha.
--
-- The bar shows the blur through its 0.75 background (shell.bar.toml).
hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true, ignore_alpha = 0.15 })

-- The menu is a full-screen layer: a 0.3 scrim with a 0.6 card on top
-- (shell.menu.toml), about 0.72 where they overlap. A 0.5 threshold blurs the
-- card and leaves the background behind the scrim sharp.
hl.layer_rule({ match = { namespace = "omarchy-menu" }, blur = true, ignore_alpha = 0.5 })
