local wezterm = require("wezterm") --[[@as Wezterm]]
local act = wezterm.action
local config = wezterm.config_builder()

local PROJECT_ROOT_PATH = "/Users/rabeezriaz/Documents/Programming"

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
  local res = string.gsub(s, "(.*[/\\])(.*)", "%2")
  return res
end

-- <<< Style elements >>>
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
config.font = wezterm.font_with_fallback({
  { family = "Maple Mono NF", weight = "Medium" },
  { family = "CaskaydiaCove Nerd Font" },
  { family = "Noto Color Emoji" },
})
config.font_size = 16
config.line_height = 1.1
config.command_palette_font_size = 18
-- These colors are copied from catppuccin palette in nvim quickfix list design
config.command_palette_bg_color = "#13121D"
config.command_palette_fg_color = "#C0CCF5"
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.window_decorations = "RESIZE"
config.initial_rows = 35
config.initial_cols = 110
config.window_padding = {
  left = 5,
  right = 5,
  top = 0,
  bottom = 5,
}

wezterm.on("window-config-reloaded", function(window, _)
  window:toast_notification("wezterm", "Configuration reloaded!", nil, 4000)
end)

-- TODO: this doesn't seem to actually update the tab title :(
-- because my custom status bar update overwrites tab name to fg process always
wezterm.on("augment-command-palette", function(_, _)
  return {
    {
      brief = "Rename tab",
      icon = "md_rename_box",

      action = act.PromptInputLine({
        description = "Enter new name for tab",
        -- initial_value = "My Tab Name",
        action = wezterm.action_callback(function(window, _, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },
    {
      brief = "Create new project and open it in workspace",
      icon = "md_new_box",
      action = act.PromptInputLine({
        description = "Enter name of project",
        action = wezterm.action_callback(function(window, pane, line)
          if not line then
            return
          end
          if line:find(" ") then
            window:toast_notification("Alert", "Input contains a space!", nil, 5000)
            return
          end

          local project_path = PROJECT_ROOT_PATH .. "/probe/" .. line
          local mkdir_cmd = { "mkdir", "-p", project_path }
          local git_init_cmd = { "git", "-C", project_path, "init" }

          wezterm.run_child_process(mkdir_cmd)
          wezterm.run_child_process(git_init_cmd)
          window:perform_action(act.SwitchToWorkspace({ name = project_path, spawn = { cwd = project_path } }), pane)
        end),
      }),
    },
  }
end)

config.color_scheme = "Catppuccin Mocha"

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    icons_enabled = true,
    theme = "Catppuccin Mocha",
    tabs_enabled = true,
    theme_overrides = {},
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    tabline_a = { "mode" },
    tabline_b = { "workspace" },
    tabline_c = { "  " },
    tab_active = {
      {
        "index",
        fmt = function(str)
          return str .. "."
        end,
      },
      { "tab", icons_enabled = false, padding = { left = 0, right = 1 } },
    },
    tab_inactive = {
      {
        "index",
        fmt = function(str)
          return str .. "."
        end,
      },
      { "tab", icons_enabled = false, padding = { left = 0, right = 1 } },
    },
    tabline_x = {},
    tabline_y = {},
    tabline_z = { "hostname" },
  },
  extensions = {},
})
-- tabline.apply_to_config(config)

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 500 }
config.colors = {
  -- NOTE: Change cursor color when wezterm LEADER is active
  compose_cursor = clr_accent_leader,
  -- NOTE: Match background color with tabline
  tab_bar = {
    background = clr_bg_dark,
  },
}

-- TODO: check repo for "major refactor" branch and redo config
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
sessionizer.apply_to_config(config, true) -- disable default binds (right now you can also just not call this)
sessionizer.config.paths = PROJECT_ROOT_PATH
sessionizer.config.command_options = {
  fd_path = "/opt/homebrew/bin/fd",
  include_submodules = false,
  max_depth = 4,
  format = "{//}",
  exclude = { "node_modules" },
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
  { key = "f", mods = "LEADER", action = sessionizer.show },
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
}

return config
