return {
  {
    "mrjones2014/smart-splits.nvim",
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
}
