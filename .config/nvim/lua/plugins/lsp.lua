return {
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "antosha417/nvim-lsp-file-operations",
    },
    config = function()
      -- Shared diagnostic helpers (used by <C-e> keymap and CursorHold autocmd)
      local diag_icons = {
        [vim.diagnostic.severity.ERROR] = { " ", "DiagnosticError" },
        [vim.diagnostic.severity.WARN] = { " ", "DiagnosticWarn" },
        [vim.diagnostic.severity.INFO] = { " ", "DiagnosticInfo" },
        [vim.diagnostic.severity.HINT] = { " ", "DiagnosticHint" },
      }

      local function diag_prefix(diagnostic, _, _)
        return unpack(diag_icons[diagnostic.severity])
      end

      local function diag_format(diagnostic)
        local max_width = 80
        local result = {}
        local space_left = max_width
        local line = ""
        for word in diagnostic.message:gmatch("%S+") do
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
            line = word
            space_left = max_width - #word
          end
        end
        if line ~= "" then
          table.insert(result, line)
        end
        return table.concat(result, "\n")
      end
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = " ",
            package_pending = " ",
            package_uninstalled = " ",
          },
        },
      })
      require("mason-lspconfig").setup({
        automatic_enable = true,
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
          "ruff",
          -- "basedpyright",
          "pyrefly",
          "yamlls",
          "taplo",
          "clangd",
          "tinymist",
          "ols",
        },
      })
      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua",
          "shellcheck",
          "sleek",
          "jsonlint",
          "glow",
          "prettierd",
          "shfmt",
          "clang-format",
          "mdformat",
        },
      })

      -- LSP custom capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

      -- Rounded borders for LSP windows
      require("lspconfig.ui.windows").default_options.border = "rounded"
      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        config = config or {}
        config.border = "rounded"
        return vim.lsp.handlers.hover(err, result, ctx, config)
      end
      vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
        config = config or {}
        config.border = "rounded"
        return vim.lsp.handlers.signature_help(err, result, ctx, config)
      end

      local function set_underline_color_from_group(diagnostic_group, source_group)
        local hl = vim.api.nvim_get_hl(0, { name = source_group, link = false })
        local fg = hl.fg
        if fg then
          local hex = string.format("#%06x", fg)
          vim.api.nvim_set_hl(0, diagnostic_group, { underline = true, sp = hex })
        else
          -- fallback: just underline without custom sp color
          vim.api.nvim_set_hl(0, diagnostic_group, { underline = true })
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          set_underline_color_from_group("DiagnosticUnderlineError", "ErrorMsg")
          set_underline_color_from_group("DiagnosticUnderlineWarn", "WarningMsg")
          set_underline_color_from_group("DiagnosticUnderlineInfo", "DiagnosticInfo")
          set_underline_color_from_group("DiagnosticUnderlineHint", "DiagnosticHint")
        end,
      })

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
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
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

      -- LSP configuration
      -- reference to check `default_config` lua object: https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/basedpyright.lua
      vim.lsp.config("*", {
        capabilities = capabilities,
      })
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Disable",
              keywordSnippet = "Disable",
            },
          },
        },
      })
      vim.lsp.config("rust_analyzer", {
        settings = {
          completion = {
            capable = {
              snippets = "add_parenthesis",
            },
          },
        },
      })
      vim.lsp.config("bashls", {
        filetypes = { "sh", "zsh" },
      })
      vim.lsp.config("html", {
        filetypes = { "html", "templ", "jinja" },
      })
      vim.lsp.config("cssls", {
        filetypes = { "html", "css", "templ", "jinja" },
      })
      vim.lsp.config("htmx", {
        filetypes = { "html", "templ", "jinja" },
      })
      vim.lsp.config("templ", {
        filetypes = { "templ" },
      })
      vim.lsp.config("tailwindcss", {
        filetypes = { "html", "templ", "astro", "javascript", "typescript", "typescriptreact", "react", "jinja" },
        settings = {
          tailwindCSS = {
            includeLanguages = {
              templ = "html",
              htmlangular = "html",
            },
          },
        },
      })
      vim.lsp.config("tinymist", {
        settings = {
          formatterMode = "typstyle",
          exportPdf = "onType",
        },
      })
      vim.lsp.config("pyrefly", {
        root_markers = {
          "pyrefly.toml",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          ".git",
          "ruff.toml",
          "pixi.toml",
        },
      })
      vim.lsp.config("ruff", {
        on_attach = function(client, _)
          client.server_capabilities.hoverProvider = false
        end,
        init_options = {
          settings = {
            args = {},
          },
        },
      })

      -- Setup keybinds
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
            -- vim.lsp.buf.references,
            function()
              Snacks.picker.lsp_references({
                include_current = true,
                auto_confirm = false,
              })
            end,
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
          vim.keymap.set("n", "<C-e>", function()
            vim.diagnostic.open_float(nil, {
              border = "rounded",
              source = "always",
              prefix = diag_prefix,
              severity_sort = true,
              header = "",
              format = diag_format,
            })
          end, { buffer = event.buf, desc = "LSP: Open hover panel for [e]rror/diagnostic under cursor" })
          vim.keymap.set(
            { "n", "i" },
            "<c-s>",
            vim.lsp.buf.signature_help,
            { buffer = event.buf, desc = "LSP: Open [s]ignature help" }
          )

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.keymap.set("n", "<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, { buffer = event.buf, desc = "[L]SP: Toggle Inlay [H]ints" })
          end

          -- Show diagnostic in hover for cursor line
          vim.api.nvim_create_autocmd("CursorHold", {
            buffer = event.buf,
            callback = function()
              vim.diagnostic.open_float(nil, {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "rounded",
                source = "always",
                prefix = diag_prefix,
                scope = "cursor",
                severity_sort = true,
                header = "",
                format = diag_format,
              })
            end,
          })

          -- Highlight symbol under cursor
          -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#highlight-symbol-under-cursor
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>lx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "[L]SP: Diagnostics (Trouble)",
      },
    },
  },
  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({
        notification = {
          window = {
            winblend = 0,
          },
        },
      })
    end,
  },
}
