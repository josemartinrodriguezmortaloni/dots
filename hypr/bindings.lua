-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Walker used Super+Space as the app launcher (desktopapplications).
-- Quattro default: Super+Space = Omarchy menu, Super+Alt+Space = apps.
-- Swap them so Super+Space stays the app viewer.
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Apps menu", "omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")

-- Media keys go to cliamp instead of omarchy-shell / system volume.
-- Note: XF86AudioPlay was previously bound to omarchy-shell media playPause.
-- Note: XF86AudioNext was previously bound to omarchy-shell media next.
-- Note: XF86AudioPrev was previously bound to omarchy-shell media previous.
-- Note: XF86AudioRaiseVolume was previously bound to omarchy-audio-output-volume raise.
-- Note: XF86AudioLowerVolume was previously bound to omarchy-audio-output-volume lower.
hl.unbind("XF86AudioPlay")
hl.unbind("XF86AudioNext")
hl.unbind("XF86AudioPrev")
hl.unbind("XF86AudioRaiseVolume")
hl.unbind("XF86AudioLowerVolume")

o.bind("XF86AudioPlay", "Cliamp toggle", "cliamp toggle", { locked = true })
o.bind("XF86AudioNext", "Cliamp next", "cliamp next", { locked = true })
o.bind("XF86AudioPrev", "Cliamp prev", "cliamp prev", { locked = true })
o.bind("XF86AudioRaiseVolume", "Cliamp volume up", "cliamp volume +3", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Cliamp volume down", "cliamp volume -3", { locked = true, repeating = true })
