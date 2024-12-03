return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						python = "python",
					}),
				},
			})

			-- 			vim.keymap.set("n", "<leader>tt", function()
			-- 				require("neotest").run.run()
			-- require("neotest").output_panel
			-- 			end, { desc = "NeoTest: Run [t]ests and show output panel" })
		end,
	},
}
