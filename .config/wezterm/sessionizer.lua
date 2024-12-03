local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local fd = "/opt/homebrew/bin/fd"
local rootPath = "/Users/rabeezriaz/Documents/Programming"

M.toggle = function(window, pane)
	local prog_projects = {}
	local full_list_of_choices = {}

	local success, stdout, stderr = wezterm.run_child_process({
		fd,
		"-HI",
		"-td",
		"^.git$",
		"--max-depth=4",
		rootPath,
		-- add more paths here
	})

	if not success then
		wezterm.log_error("Failed to run fd: " .. stderr)
		return
	end

	-- Remove directory root path to simplify list
	for line in stdout:gmatch("([^\n]*)\n?") do
		local project = line:gsub("/.git/$", "")
		local label = project
		local id = project:gsub(".*/", "")
		prog_projects[tostring(label):sub(rootPath:len() + 1)] = true
		table.insert(full_list_of_choices, { label = tostring(label):sub(rootPath:len() + 1), id = tostring(id) })
	end

	table.insert(full_list_of_choices, { label = "/Users/rabeezriaz/dotfiles", id = "dotfiles" })

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, _, id, label)
				if not id and not label then
					wezterm.log_info("Cancelled")
				else
					wezterm.log_info("Selected " .. label)
					local selection = ""
					if prog_projects[label] then
						selection = rootPath .. label
					else
						selection = label
					end
					win:perform_action(act.SwitchToWorkspace({ name = id, spawn = { cwd = selection } }), pane)
				end
			end),
			fuzzy = true,
			title = "Select project",
			choices = full_list_of_choices,
		}),
		pane
	)
end

return M
