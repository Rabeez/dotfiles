-- NOTE: These are the colorschemes shown in the custom picker
-- These mappings are from nvim name to wezterm name
AVAILABLE_COLORSCHEMES = {
  ["catppuccin-frappe"] = "Catppuccin Frappe",
  ["catppuccin-latte"] = "Catppuccin Latte",
  ["catppuccin-macchiato"] = "Catppuccin Macchiato",
  ["catppuccin-mocha"] = "Catppuccin Mocha",
  -- ["kanagawa-lotus"] = "catppuccin-macchiato", -- NOTE: not available in wezterm??
  ["kanagawa-dragon"] = "Kanagawa Dragon (Gogh)",
  ["kanagawa-wave"] = "Kanagawa (Gogh)",
  ["nightfox"] = "nightfox",
  ["dayfox"] = "dayfox",
  ["dawnfox"] = "dawnfox",
  ["duskfox"] = "duskfox",
  ["nordfox"] = "nordfox",
  ["terafox"] = "terafox",
  ["carbonfox"] = "carbonfox",
  ["tokyonight-day"] = "tokyonight_day",
  ["tokyonight-night"] = "tokyonight_night",
  ["tokyonight-moon"] = "tokyonight_moon",
  ["tokyonight-storm"] = "tokyonight_storm",
}

require("config.core")
require("config.keymaps")
require("config.lazy")
require("config.custom")

-- NOTE: Set overall default color scheme
DEFAULT_SCHEME = "catppuccin-mocha"
local filename = vim.fn.expand("$XDG_CONFIG_HOME/nvim/colorscheme")
assert(type(filename) == "string")
local file = io.open(filename, "r")
if file then
  local scheme = file:read("*a")
  if scheme ~= DEFAULT_SCHEME then
    vim.notify(" Loading nvim colorscheme from state '" .. scheme .. "'", vim.log.levels.INFO)
  end
  vim.cmd.colorscheme(scheme)
  file:close()
else
  vim.cmd.colorscheme(DEFAULT_SCHEME)
end
