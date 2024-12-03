return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					border = "double",
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"gopls",
					"html",
					"cssls",
					"bashls",
					"ts_ls",
					"jsonls",
					"markdown_oxide",
					"ruff",
					"basedpyright",
					"yamlls",
					"taplo",
					"sqlls",
				},
			})
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"shellcheck",
					"sqlfluff",
					"sql-formatter",
					"jsonlint",
					"glow",
					"prettierd",
					"shfmt",
				},
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "antosha417/nvim-lsp-file-operations" },
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			require("lspconfig.ui.windows").default_options.border = "double"
			local lspconfig = require("lspconfig")

			-- Rounded borders
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

			-- TODO: use setup_handlers method instead of this nonsense of all listed LSPs
			-- TODO: check wiki to see any LSP-specific config requirements
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.rust_analyzer.setup({ capabilities = capabilities })
			lspconfig.gopls.setup({ capabilities = capabilities })
			lspconfig.html.setup({ capabilities = capabilities })
			lspconfig.cssls.setup({ capabilities = capabilities })
			lspconfig.bashls.setup({ capabilities = capabilities, filetypes = { "sh", "zsh" } })
			lspconfig.ts_ls.setup({ capabilities = capabilities })
			lspconfig.jsonls.setup({ capabilities = capabilities })
			lspconfig.markdown_oxide.setup({ capabilities = capabilities })
			-- https://docs.astral.sh/ruff/editors/setup/#neovim
			lspconfig.ruff.setup({ capabilities = capabilities })
			lspconfig.basedpyright.setup({ capabilities = capabilities })
			lspconfig.yamlls.setup({ capabilities = capabilities })
			lspconfig.taplo.setup({ capabilities = capabilities })
			lspconfig.sqlls.setup({ capabilities = capabilities, filetypes = { "sql" } })

			-- TODO: use `LSPAttach` to have buffer specific keybinds to user specific LS functionality
			-- https://youtu.be/6pAG3BHurdM?si=v67Qo7ENJCr-PwD-&t=3990
			vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "[L]SP: Goto [d]efinition" })
			-- k("n", "gD", l.buf.declaration, bufopts)
			vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "[L]SP: Goto [i]mplementations" })
			vim.keymap.set("n", "<leader>lu", vim.lsp.buf.references, { desc = "[L]SP: Goto [u]sage/references" })
			vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, { desc = "[L]SP: Goto [t]ype definition" })
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Open hover panel for [k]eyword under cursor" })
			vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "[L]SP: Open code [a]ctions" })
			vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "[L]SP: Execute [r]ename" })
			vim.keymap.set({ "n", "i" }, "<c-s>", vim.lsp.buf.signature_help, { desc = "LSP: Open [s]ignature help" })
		end,
	},
	-- {
	-- 	"ray-x/lsp_signature.nvim",
	-- 	event = "VeryLazy",
	-- 	opts = {
	-- 		hint_enable = false,
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("lsp_signature").setup(opts)
	-- 	end,
	-- },
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			-- {
			-- 	"<leader>xX",
			-- 	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			-- 	desc = "Buffer Diagnostics (Trouble)",
			-- },
			-- {
			-- 	"<leader>cs",
			-- 	"<cmd>Trouble symbols toggle focus=false<cr>",
			-- 	desc = "Symbols (Trouble)",
			-- },
			-- {
			-- 	"<leader>cl",
			-- 	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			-- 	desc = "LSP Definitions / references / ... (Trouble)",
			-- },
			-- {
			-- 	"<leader>xL",
			-- 	"<cmd>Trouble loclist toggle<cr>",
			-- 	desc = "Location List (Trouble)",
			-- },
			-- {
			-- 	"<leader>xQ",
			-- 	"<cmd>Trouble qflist toggle<cr>",
			-- 	desc = "Quickfix List (Trouble)",
			-- },
		},
	},
	{
		"j-hui/fidget.nvim",
		opts = {
			-- options
		},
	},
}
