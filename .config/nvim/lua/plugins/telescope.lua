return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "folke/todo-comments.nvim",
      "nvim-telescope/telescope-symbols.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local previewers = require("telescope.previewers")
      local new_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        if opts.use_ft_detect == nil then
          opts.use_ft_detect = true
        end
        if filepath:match(".*%.ipynb") then
          vim.schedule(function()
            -- local tail = require("telescope.utils").path_tail(filepath)
            local cmd = 'rich "'
              .. filepath
              .. '" '
              .. "--line-numbers "
              -- NOTE: This outputs ANSI escape codes for colors but telescope just renders
              -- the raw characters instead of syntax highlighting
              -- .. "--force-terminal "
              .. "--panel=none "
              .. "--max-width=50 "
            local handle = io.popen(cmd)
            if handle == nil then
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "ERROR IN RENDERING JUPYTER NOTEBOOK VIA RICH" })
            else
              ---Split string on separator and return array
              ---@param string string
              ---@param separator string
              ---@return table
              local function split(string, separator)
                local tabl = {}
                for str in string.gmatch(string, "[^" .. separator .. "]+") do
                  table.insert(tabl, str)
                end
                return tabl
              end
              local result = handle:read("*a")
              handle:close()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, split(result, "\n"))
            end
          end)
        else
          previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end

        -- previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end
      telescope.setup({
        defaults = {
          buffer_previewer_maker = new_maker,
          path_display = { "smart" },
        },
        pickers = {
          -- NOTE: This is needed for dotfiles repo since all those files are hidden, but still need to ignore .git
          find_files = {
            -- NOTE: This is to enable color highlights of hidden files in file explorers
            hidden = true,
            find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
          },
          grep_string = {
            additional_args = { "--hidden", "--iglob", "!.git", "--case-sensitive", "-w" },
          },
          live_grep = {
            additional_args = { "--hidden", "--iglob", "!.git", "--case-sensitive", "-w" },
          },
        },
      })

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: Find [f]iles" })
      vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Telescope: Find string under [c]ursor" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: Live [g]rep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: [B]uffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: [H]elp tags" })
      vim.keymap.set("n", "<leader>ft", "<Cmd>TodoTelescope<CR>", { desc = "Telescope: List [T]ODOs" })
      vim.keymap.set("n", "<leader>fn", "<Cmd>Telescope notify<CR>", { desc = "Telescope: List [n]otifications" })

      vim.keymap.set("n", "<leader>ui", function()
        -- NOTE: Changing the colorscheme will trigger the autocmd that is defined below
        -- NOTE: 'Live preview' also triggers the autocmd
        local whitelist = {}
        for key, _ in pairs(AVAILABLE_COLORSCHEMES) do
          table.insert(whitelist, key)
        end
        local function get_whitelisted_colorschemes()
          return vim.tbl_filter(function(scheme)
            return vim.tbl_contains(whitelist, scheme)
          end, vim.fn.getcompletion("", "color"))
        end
        require("telescope.pickers")
          .new({}, {
            prompt_title = "Select Colorscheme",
            finder = require("telescope.finders").new_table({ results = get_whitelisted_colorschemes() }),
            sorter = require("telescope.config").values.generic_sorter({}),
            layout_strategy = "center",
            layout_config = {
              width = 0.3,
              height = 0.4,
            },
            previewer = false,
            attach_mappings = function(prompt_bufnr, map)
              local actions = require("telescope.actions")
              local action_state = require("telescope.actions.state")

              local function set_colorscheme()
                local entry = action_state.get_selected_entry()
                if entry then
                  vim.cmd("colorscheme " .. entry.value)
                end
              end

              -- Live preview on selection change
              actions.select_default:replace(function()
                set_colorscheme()
                actions.close(prompt_bufnr)
              end)

              -- Live preview when navigating with Telescope's built-in movements
              map("i", "<C-n>", function()
                actions.move_selection_next(prompt_bufnr)
                set_colorscheme()
              end)
              map("i", "<down>", function()
                actions.move_selection_next(prompt_bufnr)
                set_colorscheme()
              end)
              map("i", "<C-p>", function()
                actions.move_selection_previous(prompt_bufnr)
                set_colorscheme()
              end)
              map("i", "<up>", function()
                actions.move_selection_previous(prompt_bufnr)
                set_colorscheme()
              end)

              -- Close picker on single Escape press
              map("i", "<Esc>", function()
                actions.close(prompt_bufnr)
              end)

              return true
            end,
          })
          :find()
      end, { desc = "Open UI colorscheme switcher" })

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("wezterm_colorscheme", { clear = true }),
        callback = function(args)
          -- Write the colorscheme to a file for nvim
          local filename = vim.fn.expand("$XDG_CONFIG_HOME/nvim/colorscheme")
          assert(type(filename) == "string")
          local file = io.open(filename, "w")
          assert(file)
          file:write(args.match)
          file:close()

          local colorscheme = AVAILABLE_COLORSCHEMES[args.match]
          if not colorscheme then
            return
          end

          -- Write the colorscheme to a file for wezterm
          filename = vim.fn.expand("$XDG_CONFIG_HOME/wezterm/colorscheme")
          assert(type(filename) == "string")
          file = io.open(filename, "w")
          assert(file)
          file:write(colorscheme)
          file:close()

          if colorscheme ~= AVAILABLE_COLORSCHEMES[DEFAULT_SCHEME] then
            vim.notify("Setting WezTerm color scheme to '" .. colorscheme .. "'", vim.log.levels.INFO)
          end
        end,
      })

      telescope.load_extension("fzf")
      telescope.load_extension("notify")
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              -- even more opts
            }),

            -- pseudo code / specification for writing custom displays, like the one
            -- for "codeactions"
            -- specific_opts = {
            --   [kind] = {
            --     make_indexed = function(items) -> indexed_items, width,
            --     make_displayer = function(widths) -> displayer
            --     make_display = function(displayer) -> function(e)
            --     make_ordinal = function(e) -> string
            --   },
            --   -- for example to disable the custom builtin "codeactions" display
            --      do the following
            --   codeactions = false,
            -- }
          },
        },
      })
      -- To get ui-select loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    end,
  },
}
