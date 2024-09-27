return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		icons = { mappings = true, keys = {} },
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").setup({
					window = {
						border = "double", -- none, single, double, shadow
						position = "bottom", -- bottom, top
					},
				})
				-- TODO: this needs me to fix the dumb global LSP keymaps I setup
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
