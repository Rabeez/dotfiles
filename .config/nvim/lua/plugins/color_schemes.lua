return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        no_italic = true,
        integrations = {
          notify = true,
          treesitter = true,
          treesitter_context = true,
          telescope = true,
          alpha = true,
          fidget = true,
          ufo = true,
          indent_blankline = true,
          semantic_tokens = true,
          harpoon = true,
          mini = true,
          markdown = true,
          render_markdown = true,
          cmp = true,
          mason = true,
          noice = true,
          dap = true,
          dap_ui = true,
          nvim_surround = true,
          lsp_trouble = true,
          gitsigns = true,
          which_key = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
              ok = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
              ok = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
        },
      })

      -- NOTE: Set overall default color scheme
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false, -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = false },
        functionStyle = {},
        keywordStyle = { italic = false },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false, -- do not set background color
        dimInactive = false, -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = { -- add/modify theme and palette colors
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors) -- add/modify highlights
          return {}
        end,
        theme = "wave", -- Load "wave" theme
        background = { -- map the value of 'background' option to a theme
          dark = "wave", -- try "dragon" !
          light = "lotus",
        },
      })
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          styles = {
            keywords = "bold",
          },
        },
      })
    end,
  },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
      },
    },
  },
  -- {
  --   "zaldih/themery.nvim",
  --   lazy = false,
  --   config = function()
  --     require("themery").setup({
  --       themes = {
  --         "catppuccin-mocha",
  --         "catppuccin-macchiato",
  --         "catppuccin-frappe",
  --         "catppuccin-latte",
  --         "kanagawa-lotus",
  --         "kanagawa-dragon",
  --         "kanagawa-wave",
  --         "nightfox",
  --         "dayfox",
  --         "dawnfox",
  --         "duskfox",
  --         "nordfox",
  --         "terafox",
  --         "carbonfox",
  --         "tokyonight-day",
  --         "tokyonight-night",
  --         "tokyonight-moon",
  --         "tokyonight-storm",
  --         {
  --           name = "gruvbox-material-dark",
  --           colorscheme = "gruvbox-material",
  --           before = [[ vim.opt.background = "dark" ]],
  --         },
  --         {
  --           name = "gruvbox-material-light",
  --           colorscheme = "gruvbox-material",
  --           before = [[ vim.opt.background = "light" ]],
  --         },
  --       },
  --       livePreview = true,
  --       -- globalAfter = [[ require('lualine').setup({ options = { theme = require("themery").getCurrentTheme().name } }) ]],
  --       -- globalAfter = [[ vim.print(require("themery").getCurrentTheme().name) ]],
  --       globalAfter = [[
  --       local themery = require('themery')
  --       local currentTheme = themery.getCurrentTheme()
  --       vim.print(currentTheme)
  --
  --       if currentTheme then
  --         require('lualine').setup({ options = { theme = currentTheme.name or 'catppuccin-mocha' } })
  --       end
  --       ]],
  --     })
  --   end,
  -- },
}
