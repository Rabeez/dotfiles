return {
	{
		"gbprod/substitute.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		config = function()
			local substitute = require("substitute")
			substitute.setup()

			vim.keymap.set("n", "s", substitute.operator, { desc = "Substitute with motion" })
			vim.keymap.set("n", "ss", substitute.line, { desc = "Substitute line" })
			vim.keymap.set("n", "S", substitute.eol, { desc = "Substitute to end of line" })
			vim.keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-surround").setup({
				-- NOTE: default keymaps
				-- add     ->  ys{motion}{char}
				-- delete  ->  ds{char}
				-- change  ->  cs{target}{replacement}
			})
		end,
	},
	{
		"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	},
	{
		"mbbill/undotree",
	},
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			keywords = {
				NOTE = { color = "#86C3A1" },
			},
		},
	},
	-- {
	-- 	"LunarVim/bigfile.nvim",
	-- },
	{
		"echasnovski/mini.move",
		version = "*",
		config = function()
			require("mini.move").setup()
		end,
	},
	{
		"stevearc/quicker.nvim",
		event = "FileType qf",
		---@module "quicker"
		---@type quicker.SetupOptions
		opts = {},
		config = function()
			require("quicker").setup({
				opts = {
					number = true,
				},
				keys = {
					{
						">",
						function()
							require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
						end,
						desc = "Expand quickfix context",
					},
					{
						"<",
						function()
							require("quicker").collapse()
						end,
						desc = "Collapse quickfix context",
					},
				},
			})

			vim.keymap.set("n", "<leader>q", function()
				require("quicker").toggle()
			end, {
				desc = "Toggle quickfix",
			})
			vim.keymap.set("n", "<leader>l", function()
				require("quicker").toggle({ loclist = true })
			end, {
				desc = "Toggle loclist",
			})
		end,
	},
	{
		"danymat/neogen",
		-- TODO: Add keymap with ui.input selection for what type of doctring (func, class etc)
		-- and raise error if chosen type is not supported by language of buffer
		-- or even better use an fzf-style picker??
		config = true,
		-- Uncomment next line if you want to follow only stable versions
		-- version = "*"
	},
}
