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
			"3rd/image.nvim",     -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		config = function()
			-- TODO: check if this shows untracked git files in different color
			-- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/353
			require("neo-tree").setup({
				filesystem = {
					filtered_items = {
						visible = true
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
				hijack_netrw_behavior = "open_default"
			})
			-- TODO: <C-b> has a conflict within neotree so it doesn't close an opened panel
			vim.keymap.set("n", "<leader>bb", "<Cmd>Neotree toggle last<CR>",
				{ desc = "Toggle Neotree panel", silent = true })
		end
	}
}
