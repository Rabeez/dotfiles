local wezterm = require("wezterm")
local sessionizer = require("sessionizer")
local config = wezterm.config_builder()

-- <<< Style elements >>>

local function basename(s)
	-- Isolates name of program from full absolute path of executable
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0) -- for left-most cell (the one that is highlighted)
local RIGHT_ARROW = utf8.char(0xe0b1) -- for intermediate cells
local PROJECT_ICON = utf8.char(0xe601) -- for right-most cell (the one that has a different background)
-- colors from NVIM lualine catpuccin theme
local clr_accent_normal = "#89B4FA"
local clr_accent_leader = "#FAB387"
local clr_background = "#252536" -- catpuccin NVIM lualine bg color
local clr_bg_dark = "#181825" -- for right-most cell (this color is the bg color of wezterm tab bar)
-- <<< Style elements >>>

-- NOTE: Attempt to fix terminal name in fastfetch header
-- https://wezfurlong.org/wezterm/config/lua/config/term.html
config.term = "wezterm"
config.default_workspace = "main"

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

wezterm.on("update-status", function(window, pane)
	local leader = "NORMAL"
	local accent_clr = clr_accent_normal
	if window:leader_is_active() then
		leader = "LEADER"
		accent_clr = clr_accent_leader
	end

	local workspaces = wezterm.mux:get_workspace_names()
	local elements = {
		{ Background = { Color = clr_background } },
		{ Text = " " },
		"ResetAttributes",

		{ Foreground = { Color = clr_background } },
		{ Background = { Color = accent_clr } },
		{ Text = " " .. leader .. " " },
		"ResetAttributes",

		{ Foreground = { Color = accent_clr } },
		{ Background = { Color = clr_background } },
		{ Text = SOLID_RIGHT_ARROW },
		{ Text = " [" .. tostring(#workspaces) .. "] " .. PROJECT_ICON .. " " .. window:active_workspace() .. " " },
		"ResetAttributes",

		{ Foreground = { Color = clr_background } },
		{ Background = { Color = clr_bg_dark } },
		{ Text = SOLID_RIGHT_ARROW },
	}
	window:set_left_status(wezterm.format(elements))

	elements = {}
	for _, item in ipairs(window:mux_window():tabs_with_info()) do
		if item.is_active then
			table.insert(elements, { Foreground = { Color = clr_background } })
			table.insert(elements, { Background = { Color = accent_clr } })
		else
			table.insert(elements, { Foreground = { Color = accent_clr } })
			table.insert(elements, { Background = { Color = clr_background } })
		end
		local proc_name = "< TEMP >"
		for _, pane_item in ipairs(item.tab:panes_with_info()) do
			if pane_item.is_active then
				proc_name = pane_item.pane:get_foreground_process_name()
				item.tab:set_title(basename(proc_name))
			end
		end
		table.insert(elements, { Text = " " .. item.tab:get_title() .. " " })
	end
	table.insert(elements, { Background = { Color = clr_background } })
	table.insert(elements, { Text = " " })
	window:set_right_status(wezterm.format(elements))
end)

config.color_scheme = "Catppuccin Mocha"

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.colors = {
	-- NOTE: Change cursor color when wezterm LEADER is active
	compose_cursor = clr_accent_leader,
	tab_bar = {
		background = clr_bg_dark,
	},
}
-- TODO: setup cmd+N keybind to open new pane 'smartly'
--       decide whether to do vsplit/hsplit depending on how many panes are currently open
config.keys = {
	{ key = "D", mods = "LEADER", action = wezterm.action.ShowDebugOverlay },
	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
	{ key = "f", mods = "LEADER", action = wezterm.action_callback(sessionizer.toggle) },
	{
		key = "w",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES", title = "Currently open workspaces" }),
	},
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({
			flags = "FUZZY|TABS",
			title = "Currently open tabs (in active workspace)",
		}),
	},
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
}

return config
