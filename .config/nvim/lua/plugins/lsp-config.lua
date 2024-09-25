return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "double",
        },
      })
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "gopls", "html", "cssls", "bashls", "ts_ls", "jsonls", "markdown_oxide", "ruff", "yamlls", "taplo", "sqlls", }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require('lspconfig.ui.windows').default_options.border = 'double'
      local lspconfig = require("lspconfig")

      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.html.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.bashls.setup({ capabilities = capabilities })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.jsonls.setup({ capabilities = capabilities })
      lspconfig.markdown_oxide.setup({ capabilities = capabilities })
      lspconfig.ruff_lsp.setup({ capabilities = capabilities })
      lspconfig.yamlls.setup({ capabilities = capabilities })
      lspconfig.taplo.setup({ capabilities = capabilities })
      lspconfig.sqlls.setup({ capabilities = capabilities })

      -- TODO: use `LSPAttach` to have buffer specific keybinds to user specific LS functionality
      -- https://youtu.be/6pAG3BHurdM?si=v67Qo7ENJCr-PwD-&t=3990
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    end
  },
  {
    "folke/trouble.nvim",
    opts = {},     -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
      --   TODO: this conflicts with something else
      {
        "<leader>xt",
        "<cmd>TodoTrouble<cr>",
        desc = "Open TODOs in Trouble",
      },
    },
  }
}
