return {
  -- {
  -- 	"stevearc/oil.nvim",
  -- 	opts = {},
  -- 	-- Optional dependencies
  -- 	-- dependencies = { { "echasnovski/mini.icons", opts = {} } },
  -- 	dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  -- 	config = function()
  -- 		require("oil").setup()
  -- 	end,
  -- },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      -- TODO: check if this shows untracked git files in different color
      -- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/353
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true,
          },
          follow_current_file = {
            enabled = true, -- This will find and focus the file in the active buffer every time
            --               -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
        },
        window = {
          -- toggle = true,
          position = "right",
        },
        hijack_netrw_behavior = "disabled",
        sources = {
          "filesystem",
          "buffers",
          "document_symbols",
        },
      })
      -- TODO: <C-b> has a conflict within neotree so it doesn't close an opened panel
      vim.keymap.set(
        "n",
        "<leader>et",
        "<Cmd>Neotree toggle filesystem<CR>",
        { desc = "Toggle Neotree panel", silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader>ls",
        "<Cmd>Neotree toggle document_symbols<CR>",
        { desc = "[L]SP: Toggle document [s]ymbols", silent = true }
      )
    end,
  },
  -- {
  -- 	-- NOTE: this one randomly broke
  -- 	-- "mikavilpas/yazi.nvim",
  -- 	event = "VeryLazy",
  -- 	keys = {
  -- 		-- 👇 in this section, choose your own keymappings!
  -- 		{
  -- 			"<leader>ef",
  -- 			"<cmd>Yazi<cr>",
  -- 			desc = "[E]xplorer: Open yazi at the current [f]ile",
  -- 		},
  -- 		{
  -- 			-- Open in the current working directory
  -- 			"<leader>ew",
  -- 			"<cmd>Yazi cwd<cr>",
  -- 			desc = "[E]xplorer: Open yazi in [w]orking directory",
  -- 		},
  -- 		-- {
  -- 		-- 	-- NOTE: this requires a version of yazi that includes
  -- 		-- 	-- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
  -- 		-- 	"<c-up>",
  -- 		-- 	"<cmd>Yazi toggle<cr>",
  -- 		-- 	desc = "Resume the last yazi session",
  -- 		-- },
  -- 	},
  -- 	---@type YaziConfig
  -- 	opts = {
  -- 		-- NOTE: If using this then neotree `hijack_netrw_behavior` has to be `disabled`
  -- 		open_for_directories = true,
  -- 		keymaps = {
  -- 			show_help = "<f1>",
  -- 		},
  -- 	},
  -- },
  {
    "DreamMaoMao/yazi.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    lazy = false,
    keys = {
      { "<leader>ee", "<cmd>Yazi<CR>", desc = "Toggle Yazi" },
    },
  },
}
