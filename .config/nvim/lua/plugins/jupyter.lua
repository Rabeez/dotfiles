return {
	-- {
	-- 	"meatballs/notebook.nvim",
	-- 	config = function()
	-- 		require("notebook").setup()
	-- 	end,
	-- },
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim", "willothy/wezterm.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			-- these are examples, not defaults. Please see the readme
			-- vim.g.molten_image_provider = "wezterm"
			-- vim.g.molten_output_win_max_height = 100
		end,
		config = function()
			-- I find auto open annoying, keep in mind setting this option will require setting
			-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
			vim.g.molten_auto_open_output = false

			-- this guide will be using image.nvim
			-- Don't forget to setup and install the plugin if you want to view image outputs
			vim.g.molten_image_provider = "wezterm"
			vim.g.molten_split_size = 30

			-- optional, I like wrapping. works for virt text and the output window
			vim.g.molten_wrap_output = true

			-- Output as virtual text. Allows outputs to always be shown, works with images, but can
			-- be buggy with longer images
			vim.g.molten_virt_text_output = true

			-- this will make it so the output shows up below the \`\`\` cell delimiter
			vim.g.molten_virt_lines_off_by_1 = true

			vim.keymap.set(
				"n",
				"<localleader>e",
				":MoltenEvaluateOperator<CR>",
				{ desc = "evaluate operator", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>os",
				":noautocmd MoltenEnterOutput<CR>",
				{ desc = "open output window", silent = true }
			)

			vim.keymap.set(
				"n",
				"<localleader>rr",
				":MoltenReevaluateCell<CR>",
				{ desc = "re-eval cell", silent = true }
			)
			vim.keymap.set(
				"v",
				"<localleader>r",
				":<C-u>MoltenEvaluateVisual<CR>gv",
				{ desc = "execute visual selection", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>oh",
				":MoltenHideOutput<CR>",
				{ desc = "close output window", silent = true }
			)
			vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })

			-- if you work with html outputs:
			vim.keymap.set(
				"n",
				"<localleader>mx",
				":MoltenOpenInBrowser<CR>",
				{ desc = "open output in browser", silent = true }
			)

			-- Quarto stuff
			local runner = require("quarto.runner")
			vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
			vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
			vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
			vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
			vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
			vim.keymap.set("n", "<localleader>RA", function()
				runner.run_all(true)
			end, { desc = "run all cells of all languages", silent = true })

			-- automatically import output chunks from a jupyter notebook
			-- tries to find a kernel that matches the kernel in the jupyter notebook
			-- falls back to a kernel that matches the name of the active venv (if any)
			local imb = function(e) -- init molten buffer
				vim.schedule(function()
					-- local kernels = vim.fn.MoltenAvailableKernels()
					-- local try_kernel_name = function()
					-- 	local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
					-- 	return metadata.kernelspec.name
					-- end
					-- local ok, kernel_name = pcall(try_kernel_name)
					-- if not ok or not vim.tbl_contains(kernels, kernel_name) then
					-- 	kernel_name = nil
					-- 	local venv = os.getenv("VIRTUAL_ENV")
					-- 	if venv ~= nil then
					-- 		kernel_name = string.match(venv, "/.+/(.+)")
					-- 	end
					-- end
					-- if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
					-- 	vim.cmd(("MoltenInit %s"):format(kernel_name))
					-- end

					-- NOTE: Assumes `nvim` is executed from a shell with correct conda env active
					-- so here we directly execute the `python` executable in PATH
					vim.cmd("MoltenInit python")
					vim.cmd("MoltenImportOutput")

					-- Dynamically check active conda environment
					-- local venv = os.getenv("CONDA_PREFIX")
					-- if venv ~= nil then
					-- 	-- in the form of /home/benlubas/.virtualenvs/VENV_NAME
					-- 	venv = string.match(venv, "/.+/(.+)")
					-- 	vim.cmd(("MoltenInit %s"):format(venv))
					-- else
					-- 	vim.cmd("MoltenInit python3")
					-- end
				end)
			end

			local molten_augroup = vim.api.nvim_create_augroup("MoltenJupyter", { clear = true })

			-- automatically import output chunks from a jupyter notebook
			vim.api.nvim_create_autocmd("BufAdd", {
				group = molten_augroup,
				pattern = { "*.ipynb" },
				callback = imb,
			})

			-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
			vim.api.nvim_create_autocmd("BufEnter", {
				group = molten_augroup,
				pattern = { "*.ipynb" },
				callback = function(e)
					if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
						imb(e)
					end
				end,
			})

			-- automatically export output chunks to a jupyter notebook on write
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = molten_augroup,
				pattern = { "*.ipynb" },
				callback = function()
					if require("molten.status").initialized() == "Molten" then
						vim.cmd("MoltenExportOutput!")
					end
				end,
			})

			-- change the configuration when editing a python file
			vim.api.nvim_create_autocmd("BufEnter", {
				group = molten_augroup,
				pattern = "*.py",
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					if require("molten.status").initialized() == "Molten" then -- this is kinda a hack...
						vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
						vim.fn.MoltenUpdateOption("virt_text_output", false)
					else
						vim.g.molten_virt_lines_off_by_1 = false
						vim.g.molten_virt_text_output = false
					end
				end,
			})

			-- Undo those config changes when we go back to a markdown or quarto file
			vim.api.nvim_create_autocmd("BufEnter", {
				group = molten_augroup,
				pattern = { "*.qmd", "*.md", "*.ipynb" },
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					if require("molten.status").initialized() == "Molten" then
						vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
						vim.fn.MoltenUpdateOption("virt_text_output", true)
					else
						vim.g.molten_virt_lines_off_by_1 = true
						vim.g.molten_virt_text_output = true
					end
				end,
			})

			-- Provide a command to create a blank new Python notebook
			-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
			-- if you use another language than Python, you should change it in the template.
			local default_notebook = [[
			  {
			    "cells": [
			     {
			      "cell_type": "markdown",
			      "metadata": {},
			      "source": [
				""
			      ]
			     },
				 {
				  "cell_type": "python",
				  "metadata": {},
				  "source": [
				  ""
				  ]
				 }
			    ],
			    "metadata": {
			     "kernelspec": {
			      "display_name": "Python 3",
			      "language": "python",
			      "name": "python3"
			     },
			     "language_info": {
			      "codemirror_mode": {
				"name": "ipython"
			      },
			      "file_extension": ".py",
			      "mimetype": "text/x-python",
			      "name": "python",
			      "nbconvert_exporter": "python",
			      "pygments_lexer": "ipython3"
			     }
			    },
			    "nbformat": 4,
			    "nbformat_minor": 5
			  }
			]]

			local function new_notebook(filename)
				local path = filename .. ".ipynb"
				local file = io.open(path, "w")
				if file then
					file:write(default_notebook)
					file:close()
					vim.cmd("edit " .. path)
				else
					vim.notify("Could not open new notebook file for writing.", vim.log.levels.ERROR)
				end
			end

			vim.api.nvim_create_user_command("NewNotebook", function(opts)
				new_notebook(opts.args)
			end, {
				nargs = 1,
				complete = "file",
			})

			-- TODO: Custom highlight groups
			-- NOTE: Apparantly all cell output (x more lines, actual code output, traceback etc)
			-- all of it is treated as MoltenVirtualText
			local tb = require("catppuccin.palettes").get_palette("mocha")
			vim.api.nvim_set_hl(0, "MoltenVirtualText", { fg = tb.text, bg = tb.base })
			vim.api.nvim_set_hl(0, "MoltenOutputFooter", { fg = tb.green, bg = tb.base, bold = true })
			vim.api.nvim_set_hl(0, "MoltenOutputBorderFail", { fg = tb.red, bg = tb.red })
		end,
	},
	{
		"GCBallesteros/jupytext.nvim",
		config = function()
			require("jupytext").setup({
				style = "markdown",
				output_extension = "md",
				force_ft = "markdown",
			})
		end,
	},
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			local quarto = require("quarto")
			quarto.setup({
				lspFeatures = {
					languages = { "r", "python" },
					chunks = "all",
					diagnostics = {
						enabled = true,
						triggers = { "BufWritePost" },
					},
					completion = {
						enabled = true,
					},
				},
				-- keymap = {
				-- 	--TODO: setup your own keymaps:
				-- 	hover = "H",
				-- 	definition = "gd",
				-- 	rename = "<leader>rn",
				-- 	references = "gr",
				-- 	format = "<leader>gf",
				-- },
				codeRunner = {
					enabled = true,
					default_method = "molten",
				},
			})
		end,
	},
}
