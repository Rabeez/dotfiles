return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				no_italic = true,
				integrations = {
					notify = true,
					telescope = true,
					alpha = true,
					fidget = true,
					ufo = true,
					indent_blankline = true,
					harpoon = true,
					mini = true,
					markdown = true,
					render_markdown = true,
					cmp = true,
					mason = true,
					noice = true,
					dap = true,
					dap_ui = true,
					nvim_surround = true,
					lsp_trouble = true,
					gitsigns = true,
					which_key = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
							ok = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
							ok = { "underline" },
						},
						inlay_hints = {
							background = true,
						},
					},
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"stevearc/dressing.nvim",
		-- event = "VeryLazy",
		config = function()
			require("dressing").setup()
		end,
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			local nvim_notify = require("notify")
			nvim_notify.setup({
				timeout = 2000,
				render = "wrapped-compact",
				fps = 60,
				stages = "static",
			})
			vim.notify = nvim_notify
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPre", "BufNewFile" },
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
		config = function()
			-- TODO: make highlight line a dimmer grey color
			require("ibl").setup({
				scope = {
					show_start = false,
					show_end = false,
				},
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local lazy_status = require("lazy.status")
			require("lualine").setup({
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename", "encoding" },
					lualine_x = {
						-- NOTE: this needs Molten as a dependency here I think
						-- look into setting this lualine mod from within Molten config instead
						-- {
						-- 	require("molten.status").kernels(),
						-- 	cond = require("molten.status").initialized() == "Molten",
						-- },
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
						},
					},
					lualine_y = { "fileformat", "filetype" },
					lualine_z = { "location" },
				},
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { focusable = false })
			end,
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				-- Disable cmdline suggestions since cmp-cmdline is used instead
				popupmenu = {
					enabled = false,
				},
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
				},
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = true, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = true, -- add a border to hover docs and signature help
				},
			})
		end,
		-- vim.keymap.set("n", "<Esc>", function()
		-- 	require("notify").dismiss()
		-- end, { desc = "dismiss notify popup and clear hlsearch" }),
	},
	{
		"folke/zen-mode.nvim",
		opts = {
			-- TODO: ensure wezterm status/tab bar is hidden when zen mode is triggered
		},
	},
	{
		-- Highlight word instances under cursor
		"RRethy/vim-illuminate",
	},
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy", -- Or `LspAttach`
		priority = 1000, -- needs to be loaded in first
		config = function()
			-- Need to disable default virtual text diagnostic messages
			vim.diagnostic.config({ virtual_text = false })
			require("tiny-inline-diagnostic").setup({
				preset = "modern",
				options = {
					show_source = true,
					multiple_diag_under_cursor = true,
					multilines = true,
					show_all_diags_on_cursorline = true,
					-- format = function(diagnostic)
					-- 	return diagnostic.message .. " <" .. diagnostic.source .. ">"
					-- end,
				},
			})
		end,
	},
}
