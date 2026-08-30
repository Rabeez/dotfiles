-- Multiplexer integration for Neovim.
--
-- Two mutually exclusive backends, selected by whether we are inside herdr:
--
--   herdr  ($HERDR_ENV == "1")  -> herdr-splits.nvim
--   tmux   (everything else)    -> smart-splits.nvim
--
-- Both provide ctrl+hjkl navigation that crosses seamlessly between Neovim
-- splits and multiplexer panes. herdr-splits pairs with the herdr-side plugin
-- (`herdr plugin list`), which routes those chords to Neovim or to herdr
-- depending on what the focused pane is running -- the equivalent of tmux's
-- @pane-is-vim conditional.
--
-- Pane resizing is intentionally left to the multiplexer (herdr: prefix+r)
-- rather than alt+hjkl, which mini.move already uses.

local in_herdr = vim.env.HERDR_ENV == "1"

return {
  {
    "mrjones2014/smart-splits.nvim",
    cond = not in_herdr,
    dependencies = { "kwkarlwang/bufresize.nvim" },
    lazy = false,
    config = function()
      require("bufresize").setup()
      require("smart-splits").setup({
        resize_mode = {
          hooks = {
            on_leave = require("bufresize").register,
          },
        },
      })

      vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, { noremap = true, silent = true })
      vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, { noremap = true, silent = true })
      vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, { noremap = true, silent = true })
      vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { noremap = true, silent = true })
    end,
  },

  {
    "lmilojevicc/herdr-splits.nvim",
    cond = in_herdr,
    event = "VeryLazy",
    config = function()
      -- NOTE: resize_keys are deliberately NOT bound. herdr-splits defaults to
      -- alt+hjkl, which mini.move already owns for moving lines/selections in
      -- normal and visual mode. Pane resizing is done with herdr's native
      -- resize mode instead (prefix+r), so mini.move keeps working unchanged.
      require("herdr-splits").setup({
        at_edge = "wrap",
        nav_at_edge = "wrap",
        unzoom_on_nav = true,
        nav_keys = { left = "<C-h>", down = "<C-j>", up = "<C-k>", right = "<C-l>" },
      })
    end,
    keys = {
      { "<C-h>", function() require("herdr-splits").move_cursor_left() end, desc = "Navigate left" },
      { "<C-j>", function() require("herdr-splits").move_cursor_down() end, desc = "Navigate down" },
      { "<C-k>", function() require("herdr-splits").move_cursor_up() end, desc = "Navigate up" },
      { "<C-l>", function() require("herdr-splits").move_cursor_right() end, desc = "Navigate right" },
    },
  },
}
