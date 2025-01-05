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
					border = "rounded",
				},
			})
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"gopls",
					"templ",
					"htmx",
					"html",
					"cssls",
					"tailwindcss",
					"bashls",
					"ts_ls",
					"jsonls",
					"markdown_oxide",
					"ruff",
					"basedpyright",
					"yamlls",
					"taplo",
					"sqlls",
					"clangd",
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
					"clang-format",
					"mdformat",
				},
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- Rounded borders
			require("lspconfig.ui.windows").default_options.border = "rounded"
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

			vim.diagnostic.config({
				severity_sort = true,
				virtual_text = false,
				underline = {
					severity = {
						min = vim.diagnostic.severity.WARN,
					},
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.INFO] = "",
						[vim.diagnostic.severity.HINT] = "",
					},
					linehl = {
						[vim.diagnostic.severity.ERROR] = "ErrorMsg",
					},
					numhl = {
						[vim.diagnostic.severity.ERROR] = "ErrorMsg",
						[vim.diagnostic.severity.WARN] = "WarningMsg",
					},
				},
			})

			require("mason-lspconfig").setup_handlers({
				-- The first entry (without a key) will be the default handler
				-- and will be called for each installed server that doesn't have
				-- a dedicated handler.
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({ capabilities = capabilities })
				end,
				-- Next, you can provide a dedicated handler for specific servers.
				["bashls"] = function()
					require("lspconfig").bashls.setup({ capabilities = capabilities, filetypes = { "sh", "zsh" } })
				end,
				["sqlls"] = function()
					require("lspconfig").sqlls.setup({ capabilities = capabilities, filetypes = { "sql" } })
				end,
				["html"] = function()
					require("lspconfig").html.setup({ capabilities = capabilities, filetypes = { "html", "templ" } })
				end,
				["htmx"] = function()
					require("lspconfig").htmx.setup({ capabilities = capabilities, filetypes = { "html", "templ" } })
				end,
				["templ"] = function()
					require("lspconfig").templ.setup({ capabilities = capabilities, filetypes = { "templ" } })
				end,
				["tailwindcss"] = function()
					require("lspconfig").tailwindcss.setup({
						capabilities = capabilities,
						filetypes = { "html", "templ", "astro", "javascript", "typescript", "react" },
						settings = {
							tailwindCSS = {
								includeLanguages = {
									templ = "html",
									htmlangular = "html",
								},
							},
						},
					})
				end,
				["basedpyright"] = function()
					require("lspconfig").basedpyright.setup({
						-- NOTE: Disabling this kills ALL diagnostics/hints including type-checking
						-- handlers = {
						-- 	["textDocument/publishDiagnostics"] = function() end,
						-- },
						on_attach = function(client, _)
							client.server_capabilities.codeActionProvider = false
						end,
						settings = {
							basedpyright = {
								disableOrganizeImports = true,
								analysis = {
									autoSearchPaths = true,
									typeCheckingMode = "standard",
									useLibraryCodeForTypes = true,
								},
							},
						},
					})
				end,
				["ruff"] = function()
					require("lspconfig").ruff.setup({
						on_attach = function(client, _)
							client.server_capabilities.hoverProvider = false
						end,
						init_options = {
							settings = {
								args = {},
							},
						},
					})
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

					-- Show diagnostic in hover for cursor line
					-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-line-diagnostics-automatically-in-hover-window
					vim.api.nvim_create_autocmd("CursorHold", {
						buffer = event.buf,
						callback = function()
							local opts = {
								focusable = false,
								close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
								border = "rounded",
								source = "always",
								prefix = "",
								scope = "cursor",
								severity_sort = true,
								header = "",
								format = function(diagnostic)
									-- Just a simple text wrap to split long diagnostic into multiple lines
									local max_width = 80
									local result = {}
									local space_left = max_width
									local line = ""

									-- Split the text into words
									for word in diagnostic.message:gmatch("%S+") do
										-- If there's enough space for the word, add it
										if #word + 1 <= space_left then
											if line == "" then
												line = word
												space_left = space_left - #word
											else
												line = line .. " " .. word
												space_left = space_left - (#word + 1)
											end
										else
											table.insert(result, line)
											-- Start a new line and calculate space for the new word
											line = word
											space_left = max_width - #word
										end
									end

									-- Add the final line if not already added
									if line ~= "" then
										table.insert(result, line)
									end

									-- Return the wrapped text joined by newline
									return table.concat(result, "\n")
								end,
							}
							vim.diagnostic.open_float(nil, opts)
						end,
					})

					-- Highlight symbol under cursor
					-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#highlight-symbol-under-cursor
					if client and client.server_capabilities.documentHighlightProvider then
						local tb = require("catppuccin.palettes").get_palette("mocha")
						local namespace = vim.api.nvim_create_namespace("lsp-doc-highlight")
						vim.api.nvim_set_hl(namespace, "LspReferenceRead", { bg = tb.surface1 })
						vim.api.nvim_set_hl(namespace, "LspReferenceText", { bg = tb.surface1 })
						vim.api.nvim_set_hl(namespace, "LspReferenceWrite", { bg = tb.surface1 })

						vim.api.nvim_create_augroup("lsp_document_highlight", {
							clear = false,
						})
						vim.api.nvim_clear_autocmds({
							buffer = event.buf,
							group = "lsp_document_highlight",
						})
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							group = "lsp_document_highlight",
							buffer = event.buf,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							group = "lsp_document_highlight",
							buffer = event.buf,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})
		end,
	},
	-- {
	-- NOTE: Noice builtin helper looks much better, even though it stops showing when cmp popup is triggered
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
