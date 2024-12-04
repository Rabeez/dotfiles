return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>?",
			function()
				-- TODO: this needs me to fix the dumb global LSP keymaps I setup
				require("which-key").show({ global = false })
			end,
			desc = "Buffer local keymaps",
		},
	},
	config = function()
		local wk = require("which-key")
		wk.setup({

			preset = "modern",
			win = {
				border = "single", -- none, single, double, shadow
				width = 0.8,
			},
		})
		wk.add({
			{ "<leader>l", group = "[L]SP", icon = { icon = "", color = "purple" } },
			{ "<leader>g", group = "[G]it", icon = { icon = "󰊢", color = "red" } },
			{ "<leader>e", group = "File [e]xplorer", icon = { icon = "", color = "azure" } },
			{ "<leader>d", group = "[D]ebugger", icon = { icon = "", color = "purple" } },
			{ "<leader>f", group = "Telescope fuzzy [f]inder", icon = { icon = "", color = "azure" } },
			{ "<leader>h", group = "[H]arpoon", icon = { icon = "", color = "azure" } },
			{ "<leader>m", group = "[M]olten", icon = { icon = "󰺿", color = "yellow" } },
		})
	end,
}
