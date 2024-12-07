return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			local config = require("nvim-treesitter.configs")
			config.setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query",
					"javascript",
					"html",
					"css",
					"python",
					"regex",
					"rust",
					"go",
					"bash",
					"json",
					"ini",
					"yaml",
					"toml",
					"markdown",
					"markdown_inline",
					"sql",
					"gitignore",
				},
				sync_install = false,
				auto_install = true,
				autotag = { enable = true },
				-- https://www.reddit.com/r/neovim/comments/1cyta15/comment/l5l5m6c/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
				highlight = {
					enable = true,
					-- TODO: This somehow breaks injected highlighting in jupyter notebooks
					-- disable = function(lang, buf)
					-- 	if lang == "html" then
					-- 		return true
					-- 	end
					-- 	-- This is needed to ensure the Molten/Jupyter notebook works
					-- 	if lang == "markdown" then
					-- 		return true
					-- 	end
					-- 	local max_filesize = 100 * 1024 -- 100 KB
					-- 	local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					-- 	if ok and stats and stats.size > max_filesize then
					-- 		vim.notify(
					-- 			"File larger than 100KB treesitter disabled for performance",
					-- 			vim.log.levels.WARN,
					-- 			{ title = "Treesitter" }
					-- 		)
					-- 		return true
					-- 	end
					-- end,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						-- TODO: decrement doesnt work properly
						node_decremental = "<C-BS>",
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,

						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,

						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
							["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
							["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
							["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

							-- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
							["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
							["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
							["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
							["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },

							["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
							["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

							["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
							["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

							["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
							["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

							["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
							["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

							["am"] = {
								query = "@function.outer",
								desc = "Select outer part of a method/function definition",
							},
							["im"] = {
								query = "@function.inner",
								desc = "Select inner part of a method/function definition",
							},

							["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
							["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },

							["ib"] = { query = "@code_cell.inner", desc = "in block" },
							["ab"] = { query = "@code_cell.outer", desc = "around block" },
						},
					},
					-- swap = {
					-- 	enable = true,
					-- 	swap_next = {
					-- 		["<leader>na"] = "@parameter.inner", -- swap parameters/argument with next
					-- 		["<leader>n:"] = "@property.outer", -- swap object property with next
					-- 		["<leader>nm"] = "@function.outer", -- swap function with next
					-- 		["<leader>sbl"] = "@code_cell.outer",
					-- 	},
					-- 	swap_previous = {
					-- 		["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
					-- 		["<leader>p:"] = "@property.outer", -- swap object property with prev
					-- 		["<leader>pm"] = "@function.outer", -- swap function with previous
					-- 		["<leader>sbh"] = "@code_cell.outer",
					-- 	},
					-- },
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]f"] = { query = "@call.outer", desc = "Next [f]unction call start" },
							["]m"] = { query = "@function.outer", desc = "Next [m]ethod/function def start" },
							["]c"] = { query = "@class.outer", desc = "Next [c]lass start" },
							["]i"] = { query = "@conditional.outer", desc = "Next [i]f-statement/conditional start" },
							["]l"] = { query = "@loop.outer", desc = "Next [l]oop start" },

							-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
							-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
							["]s"] = { query = "@scope", query_group = "locals", desc = "Next [s]cope" },
							["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },

							["]b"] = { query = "@code_cell.inner", desc = "Next code [b]lock/cell start" },
						},
						goto_next_end = {
							["]F"] = { query = "@call.outer", desc = "Next [F]unction call end" },
							["]M"] = { query = "@function.outer", desc = "Next [M]ethod/Function def end" },
							["]C"] = { query = "@class.outer", desc = "Next [C]lass end" },
							["]I"] = { query = "@conditional.outer", desc = "Next [I]f-statement/Conditional end" },
							["]L"] = { query = "@loop.outer", desc = "Next [L]oop end" },

							["]B"] = { query = "@code_cell.inner", desc = "Next code [B]lock/Cell end" },
						},
						goto_previous_start = {
							["[f"] = { query = "@call.outer", desc = "Prev [f]unction call start" },
							["[m"] = { query = "@function.outer", desc = "Prev [m]ethod/function def start" },
							["[c"] = { query = "@class.outer", desc = "Prev [c]lass start" },
							["[i"] = { query = "@conditional.outer", desc = "Prev [i]f-statement/conditional start" },
							["[l"] = { query = "@loop.outer", desc = "Prev [l]oop start" },

							["[b"] = { query = "@code_cell.inner", desc = "Previous code [b]lock/cell start" },
						},
						goto_previous_end = {
							["[F"] = { query = "@call.outer", desc = "Prev [F]unction call end" },
							["[M"] = { query = "@function.outer", desc = "Prev [M]ethod/Function def end" },
							["[C"] = { query = "@class.outer", desc = "Prev [C]lass end" },
							["[I"] = { query = "@conditional.outer", desc = "Prev [I]f-statement/Conditional end" },
							["[L"] = { query = "@loop.outer", desc = "Prev [L]oop end" },

							["[B"] = { query = "@code_cell.inner", desc = "Previous code [B]lock/Cell end" },
						},
					},
				},
			})

			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

			-- vim way: ; goes to the direction you were moving.
			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

			-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
			vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
			vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
			vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
			vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
		end,
	},
	{
		"dariuscorvus/tree-sitter-language-injection.nvim",
		opts = {},
	},
}
