return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            python = "python",
            runner = "pytest",
            dap = {
              justMyCode = false,
              jinja = true,
            },
          }),
        },
      })

      vim.keymap.set("n", "<leader>rt", function()
        require("neotest").run.run({
          vim.fn.expand("%"),
          strategy = "dap",
        })
        -- vim.cmd("Neotest output")
      end, { desc = "NeoTest: Run [t]ests and show output panel" })
    end,
  },
}
