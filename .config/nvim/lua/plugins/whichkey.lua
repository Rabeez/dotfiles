return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		preset = "modern",
		icons = { mappings = true, keys = {} },
		win = {
			border = "double", -- none, single, double, shadow
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				-- TODO: this needs me to fix the dumb global LSP keymaps I setup
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
