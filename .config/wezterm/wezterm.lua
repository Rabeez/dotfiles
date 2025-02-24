local wezterm = require("wezterm") --[[@as Wezterm]]
local act = wezterm.action
local config = wezterm.config_builder()

local PROJECT_ROOT_PATH = "/Users/rabeezriaz/Documents/Programming"

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
---@diagnostic disable-next-line: missing-fields
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 1.0,
}

wezterm.on("window-config-reloaded", function(window, _)
  window:toast_notification("wezterm", "Configuration reloaded!", nil, 4000)
end)

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
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]

config.command_palette_bg_color = scheme["tab_bar"]["inactive_tab"]["bg_color"]
config.command_palette_fg_color = scheme["foreground"]

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    icons_enabled = true,
    theme = config.color_scheme,
    tabs_enabled = true,
    theme_overrides = {
      tab = {
        active = { fg = scheme["ansi"][5], bg = scheme["tab_bar"]["inactive_tab"]["bg_color"] },
        inactive = { fg = scheme["foreground"], bg = scheme["tab_bar"]["inactive_tab"]["bg_color"] },
        inactive_hover = { fg = scheme["ansi"][6], bg = scheme["tab_bar"]["inactive_tab"]["bg_color"] },
      },
    },
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = "",
      right = "",
    },
  },
  sections = {
    tabline_a = { "mode" },
    tabline_b = { "workspace" },
    tabline_c = { " " },
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
    tabline_y = { "domain" },
    tabline_z = { "hostname" },
  },
  extensions = {},
})
-- tabline.apply_to_config(config)

-- Setup leader key
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 500 }

---@diagnostic disable-next-line: missing-fields
config.colors = {
  -- NOTE: Change cursor color when wezterm LEADER is active
  compose_cursor = scheme["indexed"][16],
  -- NOTE: Match background color with tabline
  tab_bar = {
    background = scheme["tab_bar"]["inactive_tab"]["bg_color"],
  },
}

-- TODO: check repo for "major refactor" branch and redo config
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
sessionizer.apply_to_config(config, true) -- disable default binds
sessionizer.config = {
  show_default = false,
  show_most_recent = false,
  paths = PROJECT_ROOT_PATH,
  command_options = {
    fd_path = "/opt/homebrew/bin/fd",
    include_submodules = false,
    max_depth = 4,
    format = "{//}",
    exclude = { "node_modules" },
  },
}

-- Global terminal keymaps
config.keys = {
  {
    key = "p",
    mods = "LEADER",
    action = "ActivateCommandPalette",
  },
  { key = "D", mods = "LEADER", action = "ShowDebugOverlay" },
  { key = "LeftArrow", mods = "OPT", action = act({ SendString = "\x1bb" }) },
  { key = "RightArrow", mods = "OPT", action = act({ SendString = "\x1bf" }) },
  { key = "f", mods = "LEADER", action = sessionizer.show },
  -- TODO: Check wezterm float PR and make tab switcher, workspace swithcer, workspace finder into float windows
  {
    key = "w",
    mods = "LEADER",
    action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES", title = "Currently open workspaces" }),
  },
  {
    key = "t",
    mods = "LEADER",
    action = act.ShowLauncherArgs({
      flags = "FUZZY|TABS",
      title = "Currently open tabs (in active workspace)",
    }),
  },
  { key = "v", mods = "LEADER", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
  { key = "h", mods = "LEADER", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
}

-- NOTE: Needs to be set after other keymaps
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config, {
  direction_keys = {
    move = { "h", "j", "k", "l" },
    resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
  },
  modifiers = {
    move = "CTRL",
    resize = "META",
  },
  log_level = "info",
})

return config
