return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	-- TODO: this doesn't seem to work for renaming in neotree
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
			-- Make custom faster animation (https://github.com/rcarriga/nvim-notify/issues/36#issuecomment-982651560)
			-- local stages = require("notify.stages").slide({})
			-- stages[2] = function(state)
			--   return {
			--     width = { state.message.width, frequency = 2.5 },
			--     col = { vim.opt.columns:get() },
			--   }
			-- end

			-- local animation_speed = 5
			-- local stages_util = require("notify.stages.util")
			-- local stages = function(direction)
			--     return {
			--         function(state)
			--             local next_height = state.message.height + 2
			--             local next_row = stages_util.available_slot(state.open_windows, next_height, direction)
			--             if not next_row then
			--                 return nil
			--             end
			--             return {
			--                 relative = "editor",
			--                 anchor = "NE",
			--                 width = 1,
			--                 height = state.message.height,
			--                 col = vim.opt.columns:get(),
			--                 row = next_row,
			--                 border = "rounded",
			--                 style = "minimal",
			--             }
			--         end,
			--         function(state)
			--             return {
			--                 width = { state.message.width, frequency = animation_speed },
			--                 col = { vim.opt.columns:get() },
			--             }
			--         end,
			--         function()
			--             return {
			--                 col = { vim.opt.columns:get() },
			--                 time = true,
			--             }
			--         end,
			--         function()
			--             return {
			--                 width = {
			--                     1,
			--                     frequency = animation_speed,
			--                     damping = 0.9,
			--                     complete = function(cur_width)
			--                         return cur_width < 2
			--                     end,
			--                 },
			--                 col = { vim.opt.columns:get() },
			--             }
			--         end,
			--     }
			-- end

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
			-- TODO: make this a dimmer grey color
			require("ibl").setup({
				-- char_highlight_list = { "#9ca0b0" }
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
					-- TODO: setup Molten kernel name/status
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
						},
					},
				},
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
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
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
			})
		end,
	},
}
