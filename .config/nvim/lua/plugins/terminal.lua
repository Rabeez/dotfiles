return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<c-\>]], desc = "Toggle terminal" },
    },
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = {
        border = "rounded",
      },
    },
  },
}
