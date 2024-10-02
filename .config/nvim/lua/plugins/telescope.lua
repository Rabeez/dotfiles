return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"folke/todo-comments.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local previewers = require("telescope.previewers")
			local new_maker = function(filepath, bufnr, opts)
				opts = opts or {}
				if opts.use_ft_detect == nil then
					opts.use_ft_detect = true
				end
				if filepath:match(".*%.ipynb") then
					vim.schedule(function()
						-- local tail = require("telescope.utils").path_tail(filepath)
						local cmd = 'rich "'
							.. filepath
							.. '" '
							.. "--line-numbers "
							-- NOTE: This outputs ANSI escape codes for colors but telescope just renders 
							-- the raw characters instead of syntax highlighting
							-- .. "--force-terminal "
							.. "--panel=none "
							.. "--max-width=50 "
						local handle = io.popen(cmd)
						if handle == nil then
							vim.api.nvim_buf_set_lines(
								bufnr,
								0,
								-1,
								false,
								{ "ERROR IN RENDERING JUPYTER NOTEBOOK VIA RICH" }
							)
						else
							local function split(string, separator)
								local tabl = {}
								for str in string.gmatch(string, "[^" .. separator .. "]+") do
									table.insert(tabl, str)
								end
								return tabl
							end
							local result = handle:read("*a")
							handle:close()
							vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, split(result, "\n"))
						end
					end)
				else
					previewers.buffer_previewer_maker(filepath, bufnr, opts)
				end

				-- previewers.buffer_previewer_maker(filepath, bufnr, opts)
			end
			telescope.setup({
				defaults = {
					buffer_previewer_maker = new_maker,
					path_display = { "smart" },
				},
				pickers = {
					-- NOTE: This is needed for dotfiles repo since all those files are hidden, but still need to ignore .git
					find_files = {
						-- NOTE: This is to enable color highlights of hidden files in file explorers
						hidden = true,
						find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
					},
					grep_string = {
						additional_args = { "--hidden", "--iglob", "!.git", "--case-sensitive", "-w" },
					},
					live_grep = {
						additional_args = { "--hidden", "--iglob", "!.git", "--case-sensitive", "-w" },
					},
				},
			})

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Telescope find string under cursor" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
			vim.keymap.set("n", "<leader>ft", "<Cmd>TodoTelescope<CR>", { desc = "Telescope list TODOs" })
			vim.keymap.set("n", "<leader>fn", "<Cmd>Telescope notify<CR>", { desc = "Telescope list notifications" })

			telescope.load_extension("fzf")
			telescope.load_extension("notify")
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({
							-- even more opts
						}),

						-- pseudo code / specification for writing custom displays, like the one
						-- for "codeactions"
						-- specific_opts = {
						--   [kind] = {
						--     make_indexed = function(items) -> indexed_items, width,
						--     make_displayer = function(widths) -> displayer
						--     make_display = function(displayer) -> function(e)
						--     make_ordinal = function(e) -> string
						--   },
						--   -- for example to disable the custom builtin "codeactions" display
						--      do the following
						--   codeactions = false,
						-- }
					},
				},
			})
			-- To get ui-select loaded and working with telescope, you need to call
			-- load_extension, somewhere after setup function:
			require("telescope").load_extension("ui-select")
		end,
	},
}
