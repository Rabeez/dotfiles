return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"leoluz/nvim-dap-go",
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")
			local ui = require("dapui")
			require("mason-nvim-dap").setup({
				ensure_installed = {
					"debugpy",
					"delve",
				},
			})

			require("dapui").setup()
			require("nvim-dap-virtual-text").setup({})

			-- Begin language-specific adapters setup
			require("dap-go").setup()

			require("dap-python").setup("python")
			require("dap-python").test_runner = "pytest"
			-- End language-specific adapters setup

			-- Start keymaps
			vim.keymap.set("n", "<Leader>dc", function()
				dap.continue()
			end, { desc = "[D]AP: [c]ontinue debugger" })
			-- vim.keymap.set("n", "<F10>", function()
			-- 	dap.step_over()
			-- end)
			-- vim.keymap.set("n", "<F11>", function()
			-- 	dap.step_into()
			-- end)
			-- vim.keymap.set("n", "<F12>", function()
			-- 	dap.step_out()
			-- end)
			vim.keymap.set("n", "<Leader>db", function()
				dap.toggle_breakpoint()
			end, { desc = "[D]AP: Toggle [b]reakpoint" })
			-- vim.keymap.set("n", "<Leader>lp", function()
			-- 	dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			-- end)
			-- vim.keymap.set("n", "<Leader>dr", function()
			-- 	dap.repl.open()
			-- end)
			-- vim.keymap.set("n", "<Leader>dl", function()
			-- 	dap.run_last()
			-- end)
			vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
				require("dap.ui.widgets").hover()
			end)
			vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
				require("dap.ui.widgets").preview()
			end)
			vim.keymap.set("n", "<Leader>df", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end)
			vim.keymap.set("n", "<Leader>ds", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end)
			vim.keymap.set("n", "<leader>?", function()
				require("dapui").eval(nil, { context = "repl", enter = true, width = 100, height = 100 })
			end)
			-- End keymaps

			-- Begin UI listeners
			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
			-- End UI listeners

			-- Begin DAP gutter indicator colors
			local tb = require("catppuccin.palettes").get_palette("mocha")

			-- https://github.com/mfussenegger/nvim-dap/discussions/355#discussioncomment-4425804
			local namespace = vim.api.nvim_create_namespace("dap-hlng")
			vim.api.nvim_set_hl(namespace, "DapBreakpoint", { ctermbg = 0, fg = tb.red, bg = tb.base })
			vim.api.nvim_set_hl(namespace, "DapLogPoint", { ctermbg = 0, fg = tb.blue, bg = tb.base })
			vim.api.nvim_set_hl(namespace, "DapStopped", { ctermbg = 0, fg = tb.green, bg = tb.base })

			vim.fn.sign_define(
				"DapBreakpoint",
				{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			)
			vim.fn.sign_define(
				"DapBreakpointCondition",
				{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			)
			vim.fn.sign_define(
				"DapBreakpointRejected",
				{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			)
			vim.fn.sign_define(
				"DapLogPoint",
				{ text = "", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" }
			)
			vim.fn.sign_define(
				"DapStopped",
				{ text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" }
			)
			-- End DAP gutter indicator colors
		end,
	},
}
