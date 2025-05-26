return {
  {
    "stevearc/dressing.nvim",
    -- event = "VeryLazy",
    config = function()
      require("dressing").setup()
    end,
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      local nvim_notify = require("notify")
      nvim_notify.setup({
        timeout = 2000,
        render = "wrapped-compact",
        fps = 60,
        stages = "static",
      })
      vim.notify = nvim_notify
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
    config = function()
      -- TODO: make highlight line a dimmer grey color
      require("ibl").setup({
        scope = {
          show_start = false,
          show_end = false,
        },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "bwpge/lualine-pretty-path",
      "letieu/harpoon-lualine",
    },
    config = function()
      ---Check number of available tool updates in Mason
      ---https://github.com/williamboman/mason.nvim/discussions/1535
      ---@return (integer | string)
      local function lualine_mason_updates()
        local registry = require("mason-registry")
        local installed_packages = registry.get_installed_package_names()
        local upgrades_available = false
        local packages_outdated = 0
        local function myCallback(success, result_or_err)
          if success then
            upgrades_available = true
            packages_outdated = packages_outdated + 1
          end
        end

        for _, pkg in pairs(installed_packages) do
          local p = registry.get_package(pkg)
          if p then
            p:check_new_version(myCallback)
          end
        end

        if upgrades_available then
          return packages_outdated
        else
          return ""
        end
      end

      ---Check number of attached Molten kernels
      ---@return (integer | string)
      local function lualine_molten_kernel()
        local ok, molten_status = pcall(function()
          return require("molten.status")
        end)
        if not ok or not molten_status then
          return ""
        end
        local ok, molten_init = pcall(molten_status.initialized)
        if not ok or not molten_init then
          return ""
        end
        if molten_init == "Molten" then
          local kernels = 0
          for _ in string.gmatch(molten_status.kernels(), "%S+") do
            kernels = kernels + 1
          end
          return kernels
        else
          return ""
        end
      end

      ---Check number of attached LSP clients
      ---@return (integer | string)
      local function lualine_lsp_count()
        local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
        local count = vim.tbl_count(attached_clients)
        return count > 0 and count or ""
      end

      ---Check number of attached Conform formatters
      ---@return (integer | string)
      local function lualine_formatters_count()
        local formatters = require("conform").list_formatters_to_run(0)
        local count = vim.tbl_count(formatters)
        return count > 0 and count or ""
      end

      ---Check number of attached nvim-lint linters
      ---@return (integer | string)
      local function lualine_linters_count()
        -- TODO: Use this to add a linter section in status bar
        -- This seems to always return empty table so....
        local linters = require("lint").get_running()
        local count = vim.tbl_count(linters)
        return count > 0 and count or ""
      end

      local pretty_path = {
        "pretty_path",
        icon_show = false,
        path_sep = "",
        directories = {
          max_depth = 4,
        },
        symbols = {
          modified = "",
          newfile = "",
        },
      }

      local harpoon_indicators = {}
      local harpoon_active_indicators = {}
      for i = 1, vim.g.harpoon_max_files do
        table.insert(harpoon_indicators, string.format(" %d ", i))
        table.insert(harpoon_active_indicators, string.format("[%d]", i))
      end

      local tb = require("catppuccin.palettes").get_palette("mocha")

      require("lualine").setup({
        options = {
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            winbar = {
              "help",
              "man",
              "startify",
              "dashboard",
              "alpha",
              "packer",
              "neogitstatus",
              "NvimTree",
              "neo-tree",
              "Trouble",
              "trouble",
              "alpha",
              "lir",
              "Outline",
              "spectre_panel",
              "toggleterm",
              "qf",
              "dap-repl",
              "dapui_console",
              "dapui_watches",
              "dapui_stacks",
              "dapui_breakpoints",
              "dapui_scopes",
            },
          },
        },
        extensions = {
          "nvim-dap-ui",
          "neo-tree",
          "man",
          "lazy",
          "mason",
          "quickfix",
          "symbols-outline",
          "trouble",
          "toggleterm",
        },
        sections = {
          lualine_a = {
            { "mode", separator = { left = "", right = "" }, right_padding = 0, left_padding = 0 },
          },
          lualine_b = {
            {
              "harpoon2",
              icon = "󰐾",
              indicators = harpoon_indicators,
              active_indicators = harpoon_active_indicators,
              separator = { left = "", right = "" },
              right_padding = 0,
              left_padding = 0,
              no_harpoon = "Harpoon not loaded",
              on_click = function()
                require("harpoon").ui:toggle_quick_menu(require("harpoon"):list(), harpoon_toggle_opts)
              end,
            },
          },
          lualine_c = {
            {
              "diagnostics",
              on_click = function()
                vim.cmd("Trouble diagnostics")
              end,
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
            {
              -- https://github.com/folke/noice.nvim/wiki/Configuration-Recipes#show-recording-messages
              require("noice").api.status.mode.get,
              cond = require("noice").api.status.mode.has,
              color = { fg = tb.yellow },
            },
          },
          lualine_x = {
            {
              -- https://github.com/williamboman/mason.nvim/discussions/1535
              lualine_mason_updates,
              icon = "",
              on_click = function()
                vim.cmd("Mason")
              end,
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              on_click = function()
                vim.cmd("Lazy")
              end,
            },
          },
          lualine_y = {
            {
              lualine_formatters_count,
              icon = "󰛖",
              on_click = function()
                vim.cmd("ConformInfo")
              end,
            },
            {
              lualine_lsp_count,
              icon = " ",
              separator = { left = "", right = "" },
              right_padding = 1,
              left_padding = 0,
              on_click = function()
                vim.cmd("LspInfo")
              end,
            },
          },
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {
          lualine_c = {
            { "filetype", icon_only = true, left_padding = 0, right_padding = 0 },
            pretty_path,
          },
          lualine_x = {},
          lualine_y = {},
        },
        inactive_winbar = {
          lualine_c = {
            { "filetype", icon_only = true, left_padding = 0, right_padding = 0 },
            pretty_path,
          },
        },
      })
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { focusable = false })
      end,
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        -- Disable cmdline suggestions since cmp-cmdline is used instead
        popupmenu = {
          enabled = true,
          backend = "nui",
        },
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
          signature = {
            enabled = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = true, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
      })
    end,
    -- vim.keymap.set("n", "<Esc>", function()
    -- 	require("notify").dismiss()
    -- end, { desc = "dismiss notify popup and clear hlsearch" }),
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      -- TODO: ensure wezterm status/tab bar is hidden when zen mode is triggered
    },
  },
  -- {
  -- 	-- Highlight word instances under cursor
  -- 	"RRethy/vim-illuminate",
  -- },
  -- {
  -- 	"rachartier/tiny-inline-diagnostic.nvim",
  -- 	event = "VeryLazy", -- Or `LspAttach`
  -- 	priority = 1000, -- needs to be loaded in first
  -- 	config = function()
  -- 		-- Need to disable default virtual text diagnostic messages
  -- 		vim.diagnostic.config({ virtual_text = false })
  -- 		require("tiny-inline-diagnostic").setup({
  -- 			preset = "modern",
  -- 			options = {
  -- 				show_source = true,
  -- 				multiple_diag_under_cursor = true,
  -- 				multilines = true,
  -- 				show_all_diags_on_cursorline = true,
  -- 				-- format = function(diagnostic)
  -- 				-- 	return diagnostic.message .. " <" .. diagnostic.source .. ">"
  -- 				-- end,
  -- 			},
  -- 		})
  -- 	end,
  -- },
  -- {
  --   "tadaa/vimade",
  --   opts = {
  --     ncmode = "windows",
  --     fadelevel = 0.7,
  --   },
  -- },
}
