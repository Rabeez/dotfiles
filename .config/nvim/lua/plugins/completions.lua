return {
  -- {
  --   "hrsh7th/nvim-cmp",
  --   event = { "InsertEnter" },
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-cmdline",
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "L3MON4D3/LuaSnip",
  --     "saadparwaiz1/cmp_luasnip",
  --     "onsails/lspkind.nvim",
  --     {
  --       "windwp/nvim-autopairs",
  --       event = { "InsertEnter" },
  --       config = true,
  --       opts = {},
  --       -- use opts = {} for passing setup options
  --       -- this is equivalent to setup({}) function
  --     },
  --   },
  --   -- opts coming from lazydev recommendations
  --   opts = function(_, opts)
  --     opts.sources = opts.sources or {}
  --     table.insert(opts.sources, {
  --       name = "lazydev",
  --       group_index = 0, -- set group index to 0 to skip loading LuaLS completions
  --     })
  --   end,
  --   config = function()
  --     local cmp = require("cmp")
  --     local lspkind = require("lspkind")
  --     local lspkind_cmp_format = lspkind.cmp_format({
  --       mode = "symbol_text",
  --       preset = "codicons",
  --       maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
  --       -- can also be a function to dynamically calculate max width such as
  --       -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
  --       ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
  --       show_labelDetails = true, -- show labelDetails in menu. Disabled by default
  --     })
  --     require("luasnip.loaders.from_vscode").lazy_load()
  --     local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  --
  --     cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  --
  --     cmp.setup({
  --       completion = {
  --         completeopt = "menu,menuone,preview,noselect",
  --       },
  --       snippet = {
  --         expand = function(args)
  --           require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
  --         end,
  --       },
  --       window = {
  --         completion = cmp.config.window.bordered(),
  --         documentation = cmp.config.window.bordered(),
  --       },
  --       -- TODO: disable arrow keys for completion selection (this conflicts with pressing arrows to move cursor)
  --       mapping = cmp.mapping.preset.insert({
  --         ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  --         ["<C-f>"] = cmp.mapping.scroll_docs(4),
  --         ["<C-Space>"] = cmp.mapping.complete(),
  --         ["<CR>"] = nil,
  --         ["<tab>"] = nil,
  --         ["<C-x>"] = cmp.mapping.abort(),
  --         ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  --       }),
  --       sources = cmp.config.sources({
  --         { name = "otter" }, -- For jupyter notebook completions
  --         { name = "nvim_lsp" },
  --         { name = "buffer", max_item_count = 5 },
  --         { name = "luasnip", max_item_count = 5 }, -- For snippets
  --         { name = "path", max_item_count = 5 },
  --       }),
  --       formatting = {
  --         format = function(entry, vim_item)
  --           vim_item.menu = "[" .. entry.source.name .. "]"
  --           return lspkind.cmp_format({})(entry, vim_item)
  --         end,
  --       },
  --     })
  --
  --     -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  --     cmp.setup.cmdline({ "/", "?" }, {
  --       -- mapping = cmp.mapping.preset.cmdline(),
  --       sources = {
  --         { name = "buffer" },
  --       },
  --     })
  --
  --     -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  --     -- cmp.setup.cmdline(":", {
  --     -- 	-- mapping = cmp.mapping.preset.cmdline(),
  --     -- 	sources = cmp.config.sources({
  --     -- 		{
  --     -- 			name = "cmdline",
  --     -- 			option = {
  --     -- 				ignore_cmds = { "Man", "!" },
  --     -- 			},
  --     -- 		}, -- Priority 1
  --     -- 		{ name = "path" }, -- Priority 2
  --     -- 	}),
  --     -- 	matching = { disallow_symbol_nonprefix_matching = false },
  --     -- })
  --   end,
  -- },
  {
    "saghen/blink.cmp",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "onsails/lspkind.nvim",
      {
        "windwp/nvim-autopairs",
        event = { "InsertEnter" },
        config = true,
        opts = {},
      },
    },
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = {},
        ["<Tab>"] = {},
      },
      fuzzy = {
        sorts = {
          "exact",
          "score",
          "sort_text",
        },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      cmdline = {
        keymap = { preset = "inherit" },
        completion = { menu = { auto_show = true } },
      },
      signature = { enabled = false },
      completion = {
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        documentation = {
          auto_show = true,
          window = { border = "rounded" },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", "source_name", gap = 1 },
            },
            treesitter = { "lsp" },
            components = {
              kind_icon = {
                text = function(ctx)
                  local icon = ctx.kind_icon
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                    if dev_icon then
                      icon = dev_icon
                    end
                  else
                    icon = require("lspkind").symbolic(ctx.kind, {
                      mode = "symbol",
                    })
                  end

                  return icon .. ctx.icon_gap
                end,

                -- Optionally, use the highlight groups from nvim-web-devicons
                -- You can also add the same function for `kind.highlight` if you want to
                -- keep the highlight groups in sync with the icons.
                highlight = function(ctx)
                  local hl = ctx.kind_hl
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                    if dev_icon then
                      hl = dev_hl
                    end
                  end
                  return hl
                end,
              },
            },
          },
        },
      },
      sources = {
        default = {
          "lsp",
          "snippets",
          "path",
          "buffer",
        },
        providers = {
          snippets = { max_items = 3 },
          path = { max_items = 3 },
          buffer = { max_items = 3 },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
