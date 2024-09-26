return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"folke/todo-comments.nvim",
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					path_display = { "smart" },
				},
				pickers = {
					-- NOTE: This is needed for dotfiles repo since all those files are hidden, but still need to ignore .git
					find_files = {
						-- NOTE: This is to enable color highlights of hidden files in file explorers
						hidden = true,
						find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
					},
					grep_string = {
						additional_args = { "--hidden", '--iglob', '!.git', '--case-sensitive', '-w' }
					},
					live_grep = {
						additional_args = { "--hidden", '--iglob', '!.git', '--case-sensitive', '-w' }
					},
				},
			})

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Telescope find string under cursor" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
			vim.keymap.set("n", "<leader>ft", "<Cmd>TodoTelescope<CR>", { desc = "Telescope list TODOs" })

			telescope.load_extension("fzf")
			telescope.load_extension("notify")
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({
							-- even more opts
						}),

						-- pseudo code / specification for writing custom displays, like the one
						-- for "codeactions"
						-- specific_opts = {
						--   [kind] = {
						--     make_indexed = function(items) -> indexed_items, width,
						--     make_displayer = function(widths) -> displayer
						--     make_display = function(displayer) -> function(e)
						--     make_ordinal = function(e) -> string
						--   },
						--   -- for example to disable the custom builtin "codeactions" display
						--      do the following
						--   codeactions = false,
						-- }
					},
				},
			})
			-- To get ui-select loaded and working with telescope, you need to call
			-- load_extension, somewhere after setup function:
			require("telescope").load_extension("ui-select")
		end,
	},
}
