return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = true })
      end,
      desc = "Buffer local keymaps",
    },
  },
  config = function()
    local wk = require("which-key")
    wk.setup({
      preset = "modern",
      win = {
        border = "rounded",
        width = 0.6,
      },
    })
    wk.add({
      { "<leader>l", group = "[L]SP", icon = { icon = "", color = "purple" } },
      { "<leader>g", group = "[G]it", icon = { icon = "󰊢", color = "red" } },
      { "<leader>e", group = "File [e]xplorer", icon = { icon = "", color = "azure" } },
      { "<leader>d", group = "[D]ebugger", icon = { icon = "", color = "purple" } },
      { "<leader>f", group = "fuzzy [f]inder", icon = { icon = "", color = "azure" } },
      { "<leader>h", group = "[H]arpoon", icon = { icon = "", color = "azure" } },
      { "<leader>m", group = "[M]olten", icon = { icon = "󰺿", color = "purple" } },
      { "<leader>a", group = "[A]I", icon = { icon = "", color = "yellow" } },
      { "<leader>t", group = "[T]erminal", icon = { icon = "", color = "green" } },
      { "<leader>u", group = "[U]tilities", icon = { icon = "󱁤", color = "yellow" } },
      { "<leader>r", group = "[R]unner", icon = { icon = "󰜎", color = "purple" } },
      { "<leader>w", group = "[W]indow", icon = { icon = "", color = "yellow" } },
    })
  end,
}
