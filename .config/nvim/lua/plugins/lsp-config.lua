return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"antosha417/nvim-lsp-file-operations",
		},
		config = function()
			require("mason").setup({
				ui = {
					border = "double",
				},
			})
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

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- Rounded borders
			require("lspconfig.ui.windows").default_options.border = "double"
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

			require("mason-lspconfig").setup_handlers({
				-- The first entry (without a key) will be the default handler
				-- and will be called for each installed server that doesn't have
				-- a dedicated handler.
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({})
				end,
				-- Next, you can provide a dedicated handler for specific servers.
				["bashls"] = function()
					require("lspconfig").bashls.setup({ capabilities = capabilities, filetypes = { "sh", "zsh" } })
				end,
				["sqlls"] = function()
					require("lspconfig").sqlls.setup({ capabilities = capabilities, filetypes = { "sql" } })
				end,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					vim.keymap.set(
						"n",
						"<leader>ld",
						vim.lsp.buf.definition,
						{ buffer = event.buf, desc = "[L]SP: Goto [d]efinition" }
					)
					-- k("n", "gD", l.buf.declaration, bufopts)
					vim.keymap.set(
						"n",
						"<leader>li",
						vim.lsp.buf.implementation,
						{ buffer = event.buf, desc = "[L]SP: Goto [i]mplementations" }
					)
					vim.keymap.set(
						"n",
						"<leader>lu",
						vim.lsp.buf.references,
						{ buffer = event.buf, desc = "[L]SP: Goto [u]sage/references" }
					)
					vim.keymap.set(
						"n",
						"<leader>lt",
						vim.lsp.buf.type_definition,
						{ buffer = event.buf, desc = "[L]SP: Goto [t]ype definition" }
					)
					vim.keymap.set(
						"n",
						"K",
						vim.lsp.buf.hover,
						{ buffer = event.buf, desc = "LSP: Open hover panel for [k]eyword under cursor" }
					)
					vim.keymap.set(
						"n",
						"<leader>la",
						vim.lsp.buf.code_action,
						{ buffer = event.buf, desc = "[L]SP: Open code [a]ctions" }
					)
					vim.keymap.set(
						"n",
						"<leader>lr",
						vim.lsp.buf.rename,
						{ buffer = event.buf, desc = "[L]SP: Execute [r]ename" }
					)
					vim.keymap.set(
						{ "n", "i" },
						"<c-s>",
						vim.lsp.buf.signature_help,
						{ buffer = event.buf, desc = "LSP: Open [s]ignature help" }
					)

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						vim.keymap.set("n", "<leader>lh", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, { buffer = event.buf, desc = "[L]SP: Toggle Inlay [H]ints" })
					end
				end,
			})
		end,
	},
	-- {
	-- Noice builtin helper looks much better, even though it stops showing when cmp popup is triggered
	-- Minor issue that can be avoided by using <C-s> insert mode keymap to manually show helper
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
				"<leader>lx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "[L]SP: Diagnostics (Trouble)",
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
