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
      -- {
      --   "<leader>n",
      --   function()
      --     Snacks.notifier.show_history()
      --   end,
      --   desc = "[F]inder: Find [n]otifications",
      -- },
      -- {
      --   "<leader>fn",
      --   function()
      --     Snacks.picker.notifications()
      --   end,
      --   desc = "[F]inder: Find [n]otifications",
      -- },
      -- vim.keymap.set("n", "<leader>fn", function()
      --   local history = require("notify").history()
      --
      --   local function trim(s)
      --     return s and s:match("^%s*(.-)%s*$") or ""
      --   end
      --   local function join_with_space(list)
      --     return table.concat(list or {}, " ")
      --   end
      --   local items = vim.tbl_map(function(n)
      --     local title = join_with_space(n.title)
      --     local msg = trim(join_with_space(n.message)):gsub("\n+", " ")
      --     return {
      --       -- snacks expects a display-able string and any payload in `value`
      --       display = string.format(
      --         "%s  [%s]  %s  %s",
      --         n.icon or " ",
      --         n.level or "",
      --         title,
      --         msg ~= "" and ("| " .. msg) or ""
      --       ),
      --       value = n,
      --       time = n.time or 0,
      --       -- include a harmless file field to avoid previewer errors if any plugin checks it
      --       file = title,
      --     }
      --   end, history)
      --
      --   require("snacks.picker").pick({
      --     title = "Notification History",
      --     items = items,
      --     format_item = function(item)
      --       return item.display
      --     end,
      --     sort = function(a, b)
      --       return (a.time or 0) > (b.time or 0)
      --     end,
      --     -- disable the previewer so nothing tries to open `file`
      --     preview = false,
      --     -- show full message on select
      --     on_select = function(item)
      --       local n = item.value
      --       local full = table.concat(n.message or {}, "\n")
      --       vim.notify(full ~= "" and full or "(no message)", vim.log.levels.INFO, {
      --         title = (n.title and n.title[1]) or "Notify",
      --       })
      --     end,
      --   })
      -- end, { desc = "[F]inder: Find [n]otifications" }),
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
