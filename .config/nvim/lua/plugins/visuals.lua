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
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"bwpge/lualine-pretty-path",
		},
		config = function()
			-- https://github.com/williamboman/mason.nvim/discussions/1535
			local function lualine_mason_updates()
				local registry = require("mason-registry")
				local installed_packages = registry.get_installed_package_names()
				local upgrades_available = false
				local packages_outdated = 0
				local function myCallback(success, result_or_err)
					if success then
						upgrades_available = true
						packages_outdated = packages_outdated + 1
					end
				end

				for _, pkg in pairs(installed_packages) do
					local p = registry.get_package(pkg)
					if p then
						p:check_new_version(myCallback)
					end
				end

				if upgrades_available then
					return packages_outdated
				else
					return ""
				end
			end

			local function lualine_molten_kernel()
				local ok, molten_status = pcall(function()
					return require("molten.status")
				end)
				if not ok or not molten_status then
					return ""
				end
				if molten_status.initialized() == "Molten" then
					return "Molten Kernels: " .. molten_status.kernels()
				else
					return ""
				end
			end

			local pretty_path = {
				"pretty_path",
				directories = {
					max_depth = 3,
				},
				symbols = {
					modified = "",
					newfile = "",
				},
			}

			require("lualine").setup({
				options = {
					theme = "catppuccin",
					disabled_filetypes = {
						winbar = {
							"help",
							"man",
							"startify",
							"dashboard",
							"alpha",
							"packer",
							"neogitstatus",
							"NvimTree",
							"Trouble",
							"trouble",
							"alpha",
							"lir",
							"Outline",
							"spectre_panel",
							"toggleterm",
							"qf",
							"dap-repl",
							"dapui_console",
							"dapui_watches",
							"dapui_stacks",
							"dapui_breakpoints",
							"dapui_scopes",
						},
					},
				},
				extensions = {
					"nvim-dap-ui",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"branch",
						"diff",
						{
							"diagnostics",
							on_click = function()
								vim.cmd("Trouble diagnostics")
							end,
						},
					},
					lualine_c = {},
					lualine_x = {
						{
							-- https://github.com/folke/noice.nvim/wiki/Configuration-Recipes#show-recording-messages
							require("noice").api.status.mode.get,
							cond = require("noice").api.status.mode.has,
							color = { fg = "#FDDB98" },
						},
						{
							lualine_mason_updates,
							icon = "",
							on_click = function()
								vim.cmd("Mason")
							end,
						},
						{
							require("lazy.status").updates,
							cond = require("lazy.status").has_updates,
							on_click = function()
								vim.cmd("Lazy")
							end,
						},
					},
					lualine_y = { "fileformat", "filetype" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				winbar = {
					lualine_c = {
						pretty_path,
					},
					lualine_x = {
						{
							lualine_molten_kernel,
							icon = "",
							on_click = function()
								vim.cmd("MoltenInfo")
							end,
						},
					},
				},
				inactive_winbar = {
					lualine_c = { pretty_path },
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
					enabled = true,
				},
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
					signature = {
						enabled = true,
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
