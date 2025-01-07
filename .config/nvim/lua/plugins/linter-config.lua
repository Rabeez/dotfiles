return {
	{
		"norcalli/nvim-colorizer.lua",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
		config = function()
			-- TODO: Move all this to lsp-config and single source of code processing
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					-- NOTE: The name of the binary is 'ruff' which automatically works for LSP purposes with lspconfig
					-- with the 'ruff server' subcommand so no additional config needed
					-- but the format subcommand 'ruff format' isn't automatically picked so need to specify 'ruff_format' here
					python = { "ruff_format", lsp_format = "fallback" },
					rust = { "rustfmt", lsp_format = "fallback" },
					go = { "goimports", "gofmt" },
					templ = { "templ" },
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					typescriptreact = { "prettierd" },
					html = { "prettierd" },
					css = { "prettierd" },
					yaml = { "prettierd" },
					json = { "jsonlint" },
					sql = { "sql-formatter" },
					zsh = { "shfmt" },
					sh = { "shfmt" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					markdown = { "mdformat" },
					jinja = { "djlint", prepend_args = { "--reformat", "--indent", "2" } },
					["*"] = { "injected" }, -- enables injected-lang formatting for all filetypes
					["_"] = { "trim_whitespace" },
				},
				notify_on_error = true,
				notify_no_formatters = true,
			})

			-- Customize the "injected" formatter
			require("conform").formatters.injected = {
				-- Set the options field
				options = {
					-- Set to true to ignore errors
					ignore_errors = false,
					-- Map of treesitter language to file extension
					-- A temporary file name with this extension will be generated during formatting
					-- because some formatters care about the filename.
					lang_to_ext = {
						bash = "sh",
						-- c_sharp = "cs",
						-- elixir = "exs",
						javascript = "js",
						-- julia = "jl",
						latex = "tex",
						markdown = "md",
						python = "py",
						-- ruby = "rb",
						-- rust = "rs",
						-- teal = "tl",
						typescript = "ts",
					},
					-- Map of treesitter language to formatters to use
					-- (defaults to the value from formatters_by_ft)
					lang_to_formatters = {},
				},
			}

			-- Keymaps
			vim.keymap.set({ "n", "v", "x" }, "<leader>lf", function()
				if vim.fn.mode() == "n" then
					require("conform").format({ async = true, lsp_fallback = true })
				else
					vim.lsp.buf.format()
				end
			end, { desc = "[L]SP: Run [f]ormatter" })
			-- vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format)
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
					-- vim.lsp.buf.format({ async = true, bufnr = args.buf })
				end,
			})

			-- https://templ.guide/commands-and-tools/ide-support/#neovim--050
			Templ_format = function()
				local bufnr = vim.api.nvim_get_current_buf()
				local filename = vim.api.nvim_buf_get_name(bufnr)
				local cmd = "templ fmt " .. vim.fn.shellescape(filename)

				vim.fn.jobstart(cmd, {
					on_exit = function()
						-- Reload the buffer only if it's still the current buffer
						if vim.api.nvim_get_current_buf() == bufnr then
							vim.cmd("e!")
						end
					end,
				})
			end
			vim.api.nvim_create_autocmd({ "BufWritePre" }, { pattern = { "*.templ" }, callback = Templ_format })
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("lint").linters_by_ft = {
				markdown = { "vale" },
				jinja = { "djlint" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					-- try_lint without arguments runs the linters defined in `linters_by_ft`
					-- for the current filetype
					require("lint").try_lint()
				end,
			})
		end,
	},
}
