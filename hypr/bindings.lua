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
