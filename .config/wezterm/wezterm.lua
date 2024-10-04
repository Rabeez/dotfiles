local wezterm = require("wezterm")
local sessionizer = require("sessionizer")
local config = wezterm.config_builder()

-- NOTE: Attempt to fix terminal name in fastfetch header
-- https://wezfurlong.org/wezterm/config/lua/config/term.html
config.term = "wezterm"

config.font = wezterm.font_with_fallback({ "CaskaydiaCove Nerd Font", "Hack Nerd Font", "Noto Color Emoji" })
config.font_size = 16
config.line_height = 1.2
-- NOTE: Fully disabling tab bar also removes status bar indicators which contains active workspace
-- config.enable_tab_bar = false
-- https://github.com/wez/wezterm/issues/2082#issuecomment-1320967574
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.window_decorations = "RESIZE"
config.initial_rows = 35
config.initial_cols = 110
config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 20,
}
wezterm.on("update-right-status", function(window, pane)
	-- TODO: Improve status bar visuals (workspace name indicator, is_leader_active)
	-- https://github.com/wez/wezterm/issues/500#issuecomment-792202306
	window:set_right_status(window:active_workspace())
end)

config.color_scheme = "Catppuccin Mocha"
-- NOTE: This might affect nvim molten notebook plot situation
-- TODO: figure out how to darken inactive pane to make difference more clear
-- local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
-- config.inactive_pane_saturation = 0.9
-- config.inactive_pane_brightness = 0.8
-- config.color_schemes = {
--     ["CustomCatppuccin"] = custom,
-- }
-- config.color_scheme = "CustomCatppuccin"

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
-- TODO: setup cmd+N keybind to open new pane 'smartly'
--       decide whether to do vsplit/hsplit depending on how many panes are currently open
config.keys = {
	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
	{ key = "f", mods = "LEADER", action = wezterm.action_callback(sessionizer.toggle) },
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
}

return config
