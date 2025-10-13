return {
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "folke/todo-comments.nvim",
    },
    opts = {},
    config = function()
      require("fzf-lua").setup({
        fzf_colors = {
          true, -- auto generate rest of fzf’s highlights?
          bg = "-1", -- -1 is transparent
          gutter = "-1",
        },
        grep = {
          hidden = true,
        },
        winopts = {
          layout = "horizontal",
          preview = {
            horizontal = "right:50%",
          },
        },
        keymap = {
          fzf = {
            ["ctrl-q"] = "select-all+accept",
          },
        },
      })
      -- NOTE: This is needed to ensure builtin pickers like LSP code actions use FzfLua
      require("fzf-lua").register_ui_select()

      vim.keymap.set(
        "n",
        "<leader>ff",
        require("fzf-lua").git_files,
        { desc = "[F]inder: Find [f]iles in git project" }
      )
      vim.keymap.set("n", "<leader>fp", require("fzf-lua").files, { desc = "[F]inder: Find [p]roject files" })
      vim.keymap.set(
        "n",
        "<leader>fc",
        require("fzf-lua").grep_cword,
        { desc = "[F]inder: Find string under [c]ursor" }
      )
      vim.keymap.set("n", "<leader>fg", require("fzf-lua").live_grep, { desc = "[F]inder: Live [g]rep" })
      vim.keymap.set("n", "<leader>fb", require("fzf-lua").buffers, { desc = "[F]inder: [B]uffers" })
      vim.keymap.set("n", "<leader>fh", require("fzf-lua").helptags, { desc = "[F]inder: [H]elp tags" })
      vim.keymap.set("n", "<leader>fk", require("fzf-lua").keymaps, { desc = "[F]inder: [K]eymaps" })
      vim.keymap.set("n", "<leader>fs", require("fzf-lua").spell_suggest, { desc = "[F]inder: [S]pellings" })
      vim.keymap.set("n", "<leader>fr", require("fzf-lua").resume, { desc = "[F]inder: [R]esume previous search" })
      vim.keymap.set("n", "<leader>ft", function()
        require("todo-comments.fzf").todo({
          prompt = "> ",
          winopts = {
            title = "TODOs",
            layout = "vertical",
            preview = {
              horizontal = "down:50%",
            },
          },
        })
      end, { desc = "[F]inder: List [T]ODOs" })
      vim.keymap.set("n", "<leader>fn", function()
        require("notify.integrations.fzf").open({
          winopts = {
            title = " asdasfd ",
          },
          actions = {
            default = function(selected)
              if #selected == 0 then
                return
              end
              vim.fn.setreg("unnamedplus", selected[1])
            end,
          },
        })
      end, { desc = "[F]inder: List [n]otifications" })
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- "nvim-telescope/telescope.nvim",
    },
    config = function()
      local harpoon = require("harpoon")

      harpoon:setup()
      local harpoon_toggle_opts = {
        title = " Harpoon ",
        border = "rounded",
        title_pos = "center",
        ui_width_ratio = 0.40,
      }

      vim.keymap.set("n", "<leader>ha", function()
        harpoon:list():add()
      end, { desc = "[H]arpoon: [A]dd current file" })

      vim.keymap.set("n", "<leader>hl", function()
        harpoon.ui:toggle_quick_menu(harpoon:list(), harpoon_toggle_opts)
      end, { desc = "[H]arpoon: [L]ist files" })

      for i = 1, vim.g.harpoon_max_files do
        vim.keymap.set("n", string.format("<A-%d>", i), function()
          harpoon:list():select(i)
        end)
      end
    end,
  },
}
