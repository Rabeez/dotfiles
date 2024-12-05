return {
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "[G]it: Open lazy git panel" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"f-person/git-blame.nvim",
		-- load the plugin at startup
		event = "VeryLazy",
		-- Because of the keys part, you will be lazy loading this plugin.
		-- The plugin wil only load once one of the keys is used.
		-- If you want to load the plugin at startup, add something like event = "VeryLazy",
		-- or lazy = false. One of both options will work.
		config = function()
			require("gitblame").setup({
				--Note how the `gitblame_` prefix is omitted in `setup`
				enabled = false,
				message_template = " <summary> • <date> • <author>", -- template for the blame message, check the Message template section for more options
				date_format = "%m-%d-%Y", -- template for the date, check Date format section for more options
				virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
			})
			vim.keymap.set("n", "<leader>gb", "<cmd>GitBlameToggle<CR>", { desc = "[G]it: Toggle line [b]lame" })
		end,
	},
}
