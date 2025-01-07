local wezterm = require("wezterm") --[[@as Wezterm]]
local act = wezterm.action
local sessionizer = require("sessionizer")
local config = wezterm.config_builder()

-- <<< Style elements >>>

---Trims string to maxixum length and appends elipses
---@param str string
---@param max_length integer
---@return string
local function trim_with_ellipsis(str, max_length)
	if #str > max_length then
		return str:sub(1, max_length - 3) .. "..."
	else
		return str
	end
end

---Isolates name of program from full absolute path of executable
---@param s string
---@return string
local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end
local SOLID_RIGHT_HALF_CIRCLE = utf8.char(0xe0b4) -- for left-most cell (the one that is highlighted)
local SOLID_LEFT_HALF_CIRCLE = utf8.char(0xe0b6) -- for left-most cell (the one that is highlighted)
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

config.use_ime = false -- Needed to ensure ctrl-based keymaps are passed to processes (eg. in nvim)
config.max_fps = 120
config.default_cursor_style = "SteadyBar"
config.font = wezterm.font_with_fallback({ "CaskaydiaCove Nerd Font", "Hack Nerd Font", "Noto Color Emoji" })
config.font_size = 16
config.line_height = 1.2
config.command_palette_font_size = 18
-- These colors are copied from catppuccin palette in nvim quickfix list design
config.command_palette_bg_color = "#13121D"
config.command_palette_fg_color = "#C0CCF5"
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
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}

wezterm.on("window-config-reloaded", function(window, pane)
	window:toast_notification("wezterm", "Configuration reloaded!", nil, 4000)
end)

-- TODO: this doesn't seem to actually update the tab title :(
-- because my custom status bar update overwrites tab name to fg process always
wezterm.on("augment-command-palette", function(window, pane)
	return {
		{
			brief = "Rename tab",
			icon = "md_rename_box",

			action = act.PromptInputLine({
				description = "Enter new name for tab",
				-- initial_value = "My Tab Name",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	}
end)

wezterm.on("update-status", function(window, pane)
	-- Determine accent color based on if wezterm leader is active
	local leader = "NORMAL"
	local accent_clr = clr_accent_normal
	if window:leader_is_active() then
		leader = "LEADER"
		accent_clr = clr_accent_leader
	end

	local workspaces = wezterm.mux:get_workspace_names()
	local elements = {
		-- Single element spacer on left edge
		{ Background = { Color = clr_background } },
		{ Text = " " },
		"ResetAttributes",

		-- Terminal input mode
		{ Foreground = { Color = clr_background } },
		{ Background = { Color = accent_clr } },
		{ Text = " " .. leader .. " " },
		"ResetAttributes",

		-- Intermediate chevron and workspace info
		{ Foreground = { Color = accent_clr } },
		{ Background = { Color = clr_background } },
		{ Text = SOLID_RIGHT_ARROW },
		{ Text = " [" .. tostring(#workspaces) .. "] " .. PROJECT_ICON .. " " .. window:active_workspace() .. " " },
		"ResetAttributes",

		-- Right chevron terminal character
		{ Foreground = { Color = clr_background } },
		{ Background = { Color = clr_bg_dark } },
		{ Text = SOLID_RIGHT_ARROW },
	}

	window:set_left_status(wezterm.format(elements))

	elements = {}
	local tab_arr = window:mux_window():tabs_with_info()
	for tab_index, item in ipairs(tab_arr) do
		-- Ensure tab name correspond to foreground process name
		local proc_name = "< TEMP >"
		for _, pane_item in ipairs(item.tab:panes_with_info()) do
			if pane_item.is_active then
				proc_name = pane_item.pane:get_foreground_process_name()
				item.tab:set_title(basename(proc_name))
			end
		end

		-- Setup colors and write left half-circle
		if not item.is_active then
			table.insert(elements, { Foreground = { Color = clr_background } })
			table.insert(elements, { Background = { Color = clr_bg_dark } })
		else
			table.insert(elements, { Foreground = { Color = accent_clr } })
			table.insert(elements, { Background = { Color = clr_bg_dark } })
		end
		table.insert(elements, { Text = SOLID_LEFT_HALF_CIRCLE })

		-- Setup colors and write tab name
		if item.is_active then
			table.insert(elements, { Foreground = { Color = clr_background } })
			table.insert(elements, { Background = { Color = accent_clr } })
		else
			table.insert(elements, { Foreground = { Color = accent_clr } })
			table.insert(elements, { Background = { Color = clr_background } })
		end
		table.insert(elements, { Text = " " .. trim_with_ellipsis(item.tab:get_title(), 10) .. " " })

		-- Setup colors and write right half-circle
		if not item.is_active then
			table.insert(elements, { Foreground = { Color = clr_background } })
			table.insert(elements, { Background = { Color = clr_bg_dark } })
		else
			table.insert(elements, { Foreground = { Color = accent_clr } })
			table.insert(elements, { Background = { Color = clr_bg_dark } })
		end
		table.insert(elements, { Text = SOLID_RIGHT_HALF_CIRCLE })

		-- Spacing between tabs, except to right side of last tab
		if tab_index ~= #tab_arr then
			table.insert(elements, { Text = " " })
		end
	end

	-- Single element spacer on right edge
	-- table.insert(elements, { Background = { Color = clr_bg_dark } })
	-- table.insert(elements, { Text = " " })

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
	{
		key = "p",
		mods = "LEADER",
		action = "ActivateCommandPalette",
	},
	{ key = "D", mods = "LEADER", action = "ShowDebugOverlay" },
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
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
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
-- TODO
-- keybind LEADER+a -> m
-- open text input to create new directory somewhere in programming root with user-specified name
-- create a git repo here
-- open this directory as a new workspace

return config
