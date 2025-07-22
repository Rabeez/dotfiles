return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    build = ":UpdateRemotePlugins",
    dependencies = {
      {
        "3rd/image.nvim",
        version = "1.1.0",
        build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        opts = {
          processor = "magick_cli",
        },
      },
      {
        "quarto-dev/quarto-nvim",
        dependencies = {
          "jmbuhr/otter.nvim",
          "nvim-treesitter/nvim-treesitter",
        },
      },
      {
        "GCBallesteros/jupytext.nvim",
        config = true,
      },
    },
    init = function()
      -- this is an example, not a default. Please see the readme for more configuration options
      -- vim.g.molten_output_win_max_height = 12

      vim.g.molten_auto_open_output = false

      -- this guide will be using image.nvim
      -- Don't forget to setup and install the plugin if you want to view image outputs
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_image_location = "virt"
      vim.g.molten_auto_image_popup = false

      -- optional, I like wrapping. works for virt text and the output window
      vim.g.molten_wrap_output = true
      vim.g.molten_use_border_highlights = true
      vim.g.molten_output_show_more = true
      vim.g.molten_output_virt_lines = true
      vim.g.molten_enter_output_behavior = "open_and_enter"

      -- Output as virtual text. Allows outputs to always be shown, works with images, but can
      -- be buggy with longer images
      vim.g.molten_virt_text_output = true

      -- this will make it so the output shows up below the \`\`\` cell delimiter
      -- NOTE: This needs to be false to work with render-markdown
      vim.g.molten_virt_lines_off_by_1 = false
    end,
    config = function()
      require("image").setup({
        backend = "kitty", -- Kitty will provide the best experience, but you need a compatible terminal
        integrations = {}, -- do whatever you want with image.nvim's integrations
        max_width = 200, -- tweak to preference
        max_height = 20, -- ^
        max_height_window_percentage = math.huge, -- this is necessary for a good experience
        max_width_window_percentage = math.huge,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { "noice" },
      })

      require("quarto").setup({
        debug = false,
        closePreviewOnExit = false,
        lspFeatures = {
          enabled = true,
          chunks = "curly",
          languages = { "python" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        codeRunner = {
          enabled = true,
          default_method = "molten", -- "molten", "slime", "iron" or <function>
          ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
          -- Takes precedence over `default_method`
          never_run = { "yaml" }, -- filetypes which are never sent to a code runner
        },
      })

      require("otter").setup({})

      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      })

      -- automatically import output chunks from a jupyter notebook
      -- tries to find a kernel that matches the kernel in the jupyter notebook
      -- falls back to a kernel that matches the name of the active venv (if any)
      local imb = function(e) -- init molten buffer
        vim.schedule(function()
          local kernels = vim.fn.MoltenAvailableKernels()
          local try_kernel_name = function()
            local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
            return metadata.kernelspec.name
          end
          local ok, kernel_name = pcall(try_kernel_name)
          if not ok or not vim.tbl_contains(kernels, kernel_name) then
            kernel_name = nil
            -- local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
            local venv = os.getenv("PIXI_ENVIRONMENT_NAME")
            if venv ~= nil then
              kernel_name = string.match(venv, "/.+/(.+)")
            end
          end
          if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
            vim.cmd(("MoltenInit %s"):format(kernel_name))
          end
          vim.cmd("MoltenImportOutput")
        end)
      end

      -- automatically import output chunks from a jupyter notebook
      vim.api.nvim_create_autocmd("BufAdd", {
        pattern = { "*.ipynb" },
        callback = imb,
      })

      -- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.ipynb" },
        callback = function(e)
          if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
            imb(e)
          end
          require("otter").activate()
        end,
      })

      -- automatically export output chunks to a jupyter notebook on write
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.ipynb" },
        callback = function()
          if require("molten.status").initialized() == "Molten" then
            vim.cmd("MoltenExportOutput!")
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
       "cell_type": "code",
       "execution_count": 1,
       "id": "Tzl0YbnPjMps",
       "metadata": {
        "id": "Tzl0YbnPjMps"
       },
       "outputs": [],
       "source": [
        "",
        "",
        "",
        ""
       ]
      }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3 (ipykernel)",
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
          print("Error: Could not open new notebook file for writing.")
        end
      end

      vim.api.nvim_create_user_command("NewNotebook", function(opts)
        new_notebook(opts.args)
      end, {
        nargs = 1,
        complete = "file",
      })

      local runner = require("quarto.runner")
      -- vim.keymap.set(
      --   "n",
      --   "<leader>e",
      --   ":MoltenEvaluateOperator<CR>",
      --   { desc = "evaluate operator", silent = true }
      -- )
      vim.keymap.set(
        "n",
        "<leader>mo",
        ":noautocmd MoltenEnterOutput<CR>",
        { desc = "[M]olten: Open [O]utput window", silent = true }
      )
      vim.keymap.set("n", "<leader>mr", runner.run_cell, { desc = "[M]olten: [R]un cell", silent = true })
      vim.keymap.set("v", "<leader>mv", runner.run_range, { desc = "[M]olten: Run [V]isual selection", silent = true })
      vim.keymap.set("v", "<leader>ml", runner.run_line, { desc = "[M]olten: Run current [L]ine", silent = true })
      -- vim.keymap.set(
      --   "n",
      --   "<leader>mh",
      --   ":MoltenHideOutput<CR>",
      --   { desc = "[M]olten: Hide [O]utput window", silent = true }
      -- )
      vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "[M]olten: [D]elete cell", silent = true })

      vim.keymap.set("n", "<leader>mi", function()
        local lines = {
          "```python",
          "",
          "",
          "```",
        }
        vim.api.nvim_put(lines, "l", true, true)
        vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1] - 2, 0 })
        vim.cmd("startinsert")
      end, { desc = "[M]olten: [I]nsert Python code block" })

      -- if you work with html outputs:
      vim.keymap.set(
        "n",
        "<localleader>mx",
        ":MoltenOpenInBrowser<CR>",
        { desc = "open output in browser", silent = true }
      )
    end,
  },
}
