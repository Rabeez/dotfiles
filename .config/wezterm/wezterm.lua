local wezterm = require("wezterm") --[[@as Wezterm]]
local act = wezterm.action
local config = wezterm.config_builder()

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
-- config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.window_decorations = "RESIZE"
config.initial_rows = 35
config.initial_cols = 110
config.audible_bell = "Disabled"
config.window_padding = {
  left = 5,
  right = 5,
  top = 0,
  bottom = 5,
}
config.tab_max_width = 30
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
    -- {
    --   brief = "Create new project and open it in workspace",
    --   icon = "md_new_box",
    --   action = act.PromptInputLine({
    --     description = "Enter name of project",
    --     action = wezterm.action_callback(function(window, pane, line)
    --       if not line then
    --         return
    --       end
    --       if line:find(" ") then
    --         window:toast_notification("Alert", "Input contains a space!", nil, 5000)
    --         return
    --       end
    --
    --       local project_path = PROJECTS_ROOT_PATH .. "/probe/" .. line
    --       local mkdir_cmd = { "mkdir", "-p", project_path }
    --       local git_init_cmd = { "git", "-C", project_path, "init" }
    --
    --       wezterm.run_child_process(mkdir_cmd)
    --       wezterm.run_child_process(git_init_cmd)
    --       window:perform_action(act.SwitchToWorkspace({ name = project_path, spawn = { cwd = project_path } }), pane)
    --     end),
    --   }),
    -- },
  }
end)

-- Colorscheme
local file = io.open(wezterm.config_dir .. "/colorscheme", "r")
if file then
  config.color_scheme = file:read("*a")
  file:close()
else
  config.color_scheme = "Catppuccin Mocha"
end
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
-- TODO: setup simpler color overrides that:
--   1. works with all themes e.g. base16 themes have very few colors defined
--   2. some light themes e.g. dawnfox have bad colors for wezterm tabline section B
--     ^ will need manual override for those few themes

-- config.command_palette_bg_color = scheme["tab_bar"]["inactive_tab"]["bg_color"]
-- config.command_palette_fg_color = scheme["foreground"]

-- TODO: solve for this from Josh Madelski dotfiles
-- can be for lazygit, bat, eza, delta etc?
-- config.set_environment_variables = {
--   BAT_THEME = h.is_dark() and "Catppuccin-mocha" or "Catppuccin-latte",
--   LC_ALL = "en_US.UTF-8",
-- }

-- Setup leader key
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 500 }

---@diagnostic disable-next-line: missing-fields
config.colors = {
  -- NOTE: Change cursor color when wezterm LEADER is active
  compose_cursor = scheme["indexed"][16],
  -- NOTE: Match background color with tabline
  tab_bar = {
    background = scheme["background"],
  },
}

-- Reference for dotfiles that pass correct keycodes to TMUX
-- https://github.com/joshmedeski/dotfiles/blob/main/.config/wezterm/wezterm.lua
local k = require("utils/keys")
config.keys = {
  {
    key = "p",
    mods = "LEADER",
    action = "ActivateCommandPalette",
  },
  { key = "D", mods = "LEADER", action = act.ShowDebugOverlay },
  k.cmd_to_tmux_prefix("t", "c"),
  k.cmd_to_tmux_prefix("w", "x"),
  k.cmd_to_tmux_prefix("z", "z"),
  k.cmd_to_tmux_prefix("l", "L"),
  k.cmd_to_tmux_prefix("1", "1"),
  k.cmd_to_tmux_prefix("2", "2"),
  k.cmd_to_tmux_prefix("3", "3"),
  k.cmd_to_tmux_prefix("4", "4"),
  k.cmd_to_tmux_prefix("5", "5"),
}

return config
