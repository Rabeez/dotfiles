local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- NOTE: Attempt to fix terminal name in fastfetch header
-- https://wezfurlong.org/wezterm/config/lua/config/term.html
config.term = "wezterm"

config.font = wezterm.font_with_fallback({ "CaskaydiaCove Nerd Font", "Hack Nerd Font", "Noto Color Emoji" })
config.font_size = 16
config.line_height = 1.2
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.initial_rows = 35
config.initial_cols = 110
config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 20,
}

config.color_scheme = "Catppuccin Mocha"
-- TODO: figure out how to darken inactive pane to make difference more clear
-- local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
-- config.inactive_pane_saturation = 0.9
-- config.inactive_pane_brightness = 0.8
-- config.color_schemes = {
--     ["CustomCatppuccin"] = custom,
-- }
-- config.color_scheme = "CustomCatppuccin"

-- TODO: setup cmd+N keybind to open new pane 'smartly'
--       decide whether to do vsplit/hsplit depending on how many panes are currently open
config.keys = {
	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
}

return config
