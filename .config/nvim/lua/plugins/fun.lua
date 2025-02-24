return {
  {
    "eandrju/cellular-automaton.nvim",
    config = function()
      vim.keymap.set("n", "<leader>uc", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "Make it Rain" })
    end,
  },
}
