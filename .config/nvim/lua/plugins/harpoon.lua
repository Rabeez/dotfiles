return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup()

			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = "[H]arpoon: [A]dd current file" })

			vim.keymap.set("n", "<leader>hl", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "[H]arpoon: [L]ist files" })

			for i = 1, vim.g.harpoon_max_files do
				vim.keymap.set("n", string.format("<A-%d>", i), function()
					harpoon:list():select(i)
				end)
			end
		end,
	},
}
