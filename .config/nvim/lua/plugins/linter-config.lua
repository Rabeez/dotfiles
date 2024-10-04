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
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff" },
					rust = { "rustfmt", lsp_format = "fallback" },
					go = { "goimports", "gofmt" },
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					html = { "prettierd" },
					css = { "prettierd" },
					yaml = { "prettierd" },
					json = { "jsonlint" },
					sql = { "sqlfluff" },
					zsh = { "shfmt" },
					sh = { "shfmt" },
					["_"] = { "trim_whitespace" },
				},
				notify_on_error = true,
				notify_no_formatters = true,
			})
			-- keymap
			vim.keymap.set("n", "<leader>gf", require("conform").format)
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
				end,
			})
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("lint").linters_by_ft = {
				markdown = { "vale" },
			}
		end,
	},
}
