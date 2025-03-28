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
    vim.notify("Loading nvim colorscheme from state " .. scheme, vim.log.levels.INFO)
  end
  vim.cmd.colorscheme(scheme)
  file:close()
else
  vim.cmd.colorscheme(DEFAULT_SCHEME)
end
