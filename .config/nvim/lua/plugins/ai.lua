return {
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = {
          -- cpp = true,
        },
        -- color = {
        --   suggestion_color = "#ffffff",
        --   cterm = 244,
        -- },
        log_level = "off",
        disable_inline_completion = false,
        disable_keymaps = false,
        condition = function()
          -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
          return false
        end,
      })
      -- require("supermaven-nvim.api").use_free_version()
      if not require("supermaven-nvim.api").is_running() then
        require("supermaven-nvim.api").start()
      end

      vim.keymap.set(
        "n",
        "<leader>aa",
        require("supermaven-nvim.api").toggle,
        { noremap = true, silent = true, desc = "[A]I: Toggle AI completion" }
      )
    end,
  },
}
