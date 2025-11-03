return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      animate = {
        enabled = true,
        style = "out",
        easing = "linear",
        duration = {
          step = 20, -- ms per step
          total = 100, -- maximum duration
        },
      },
      indent = {
        enabled = true,
        step = 1,
        only_scope = true,
        only_current = true,
        hl = "SnacksIndent",
      },
      scope = { enabled = false },
      picker = {
        enabled = true,
        ui_select = true,
      },
      notifier = {
        enabled = true,
        timeout = 2000,
        style = "compact",
        padding = false,
        icons = {
          error = "",
          warn = "",
          info = "",
          debug = "",
          trace = "",
        },
      },
    },
    keys = {
      -- find
      {
        "<leader>fp",
        function()
          Snacks.picker.files({ hidden = true })
        end,
        desc = "[F]inder: Find [p]roject files in directory",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.git_files()
        end,
        desc = "[F]inder: Find [f]iles in git project",
      },
      {
        "<leader>fo",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "[F]inder: Find LSP symbol [o]bjects",
      },
      -- Grep
      -- NOTE: picker starts in live mode
      --       type search terms
      --       anytime, press <c-g> then do 'file:lua$', then <c-g> back
      --       now you are searching only in lua files
      {
        "<leader>fg",
        function()
          Snacks.picker.grep({ hidden = true, live = true })
        end,
        desc = "[F]inder: [G]rep search",
      },
      -- search
      {
        "<leader>fh",
        function()
          Snacks.picker.help()
        end,
        desc = "[F]inder: [H]elp Pages",
      },
      {
        "<leader>fk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "[F]inder: [K]eymaps",
      },
      {
        "<leader>fm",
        function()
          Snacks.picker.man()
        end,
        desc = "[F]inder: [M]an Pages",
      },
      -- Other
      {
        "<leader>fn",
        function()
          Snacks.picker.notifications({
            confirm = function(picker, item)
              picker:close()
              if not item then
                return
              end
              local content = item.item.title .. "\n" .. item.item.msg
              vim.fn.setreg("+", content)
            end,
          })
        end,
        desc = "[F]inder: Find [n]otifications",
      },
      {
        "<leader>fs",
        function()
          Snacks.picker.spelling()
        end,
        desc = "[F]inder: Find [s]pellings",
      },
      {
        "<leader>ft",
        function()
          Snacks.picker.todo_comments({ hidden = true })
        end,
        desc = "[F]inder: [T]odo comments",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "[G]it: Lazygit",
      },
    },
  },
}
