-- Parsers to auto-install
local languages = {
  "lua",
  "vim",
  "vimdoc",
  "query",
  "javascript",
  "html",
  "css",
  "python",
  "regex",
  "rust",
  "go",
  "templ",
  "bash",
  "json",
  "ini",
  "yaml",
  "toml",
  "markdown",
  "markdown_inline",
  "sql",
  "gitignore",
  "typst",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      -- Install parsers (async, skips already-installed)
      require("nvim-treesitter").install(languages)

      -- Enable highlight, indent, fold per-buffer via FileType autocmd
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter.setup", {}),
        callback = function(args)
          local buf = args.buf
          local filetype = args.match

          local language = vim.treesitter.language.get_lang(filetype) or filetype
          if not vim.treesitter.language.add(language) then
            return
          end

          -- Highlighting
          vim.treesitter.start(buf, language)

          -- Indentation
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Custom filetype registrations
      vim.treesitter.language.register("html", "jinja")

      -- Utility keymaps
      vim.keymap.set("n", "<leader>ut", function()
        if vim.bo.filetype == "query" then
          return vim.cmd("q")
        else
          return vim.cmd("InspectTree")
        end
      end, { desc = "Toggle [T]reesitter playground" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

      -- ===== Textobject selections =====
      local select_maps = {
        ["a="] = { "@assignment.outer", "Select outer part of an assignment" },
        ["i="] = { "@assignment.inner", "Select inner part of an assignment" },
        ["l="] = { "@assignment.lhs", "Select left hand side of an assignment" },
        ["r="] = { "@assignment.rhs", "Select right hand side of an assignment" },
        ["a:"] = { "@property.outer", "Select outer part of an object property" },
        ["i:"] = { "@property.inner", "Select inner part of an object property" },
        ["l:"] = { "@property.lhs", "Select left part of an object property" },
        ["r:"] = { "@property.rhs", "Select right part of an object property" },
        ["aa"] = { "@parameter.outer", "Select outer part of a parameter/argument" },
        ["ia"] = { "@parameter.inner", "Select inner part of a parameter/argument" },
        ["ai"] = { "@conditional.outer", "Select outer part of a conditional" },
        ["ii"] = { "@conditional.inner", "Select inner part of a conditional" },
        ["al"] = { "@loop.outer", "Select outer part of a loop" },
        ["il"] = { "@loop.inner", "Select inner part of a loop" },
        ["af"] = { "@call.outer", "Select outer part of a function call" },
        ["if"] = { "@call.inner", "Select inner part of a function call" },
        ["am"] = { "@function.outer", "Select outer part of a method/function definition" },
        ["im"] = { "@function.inner", "Select inner part of a method/function definition" },
        ["ac"] = { "@class.outer", "Select outer part of a class" },
        ["ic"] = { "@class.inner", "Select inner part of a class" },
        ["ib"] = { "@code_cell.inner", "in block" },
        ["ab"] = { "@code_cell.outer", "around block" },
      }
      for key, val in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(val[1], "textobjects")
        end, { desc = val[2] })
      end

      -- ===== Move: goto next/prev start/end =====
      local move_next_start = {
        ["]f"] = { "@call.outer", "Next [f]unction call start" },
        ["]m"] = { "@function.outer", "Next [m]ethod/function def start" },
        ["]c"] = { "@class.outer", "Next [c]lass start" },
        ["]i"] = { "@conditional.outer", "Next [i]f-statement/conditional start" },
        ["]l"] = { "@loop.outer", "Next [l]oop start" },
        ["]b"] = { "@code_cell.inner", "Next code [b]lock/cell start" },
      }
      local move_next_end = {
        ["]F"] = { "@call.outer", "Next [F]unction call end" },
        ["]M"] = { "@function.outer", "Next [M]ethod/Function def end" },
        ["]C"] = { "@class.outer", "Next [C]lass end" },
        ["]I"] = { "@conditional.outer", "Next [I]f-statement/Conditional end" },
        ["]L"] = { "@loop.outer", "Next [L]oop end" },
        ["]B"] = { "@code_cell.inner", "Next code [B]lock/Cell end" },
      }
      local move_prev_start = {
        ["[f"] = { "@call.outer", "Prev [f]unction call start" },
        ["[m"] = { "@function.outer", "Prev [m]ethod/function def start" },
        ["[c"] = { "@class.outer", "Prev [c]lass start" },
        ["[i"] = { "@conditional.outer", "Prev [i]f-statement/conditional start" },
        ["[l"] = { "@loop.outer", "Prev [l]oop start" },
        ["[b"] = { "@code_cell.inner", "Previous code [b]lock/cell start" },
      }
      local move_prev_end = {
        ["[F"] = { "@call.outer", "Prev [F]unction call end" },
        ["[M"] = { "@function.outer", "Prev [M]ethod/Function def end" },
        ["[C"] = { "@class.outer", "Prev [C]lass end" },
        ["[I"] = { "@conditional.outer", "Prev [I]f-statement/Conditional end" },
        ["[L"] = { "@loop.outer", "Prev [L]oop end" },
        ["[B"] = { "@code_cell.inner", "Previous code [B]lock/Cell end" },
      }

      for key, val in pairs(move_next_start) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          move.goto_next_start(val[1], "textobjects")
        end, { desc = val[2] })
      end
      for key, val in pairs(move_next_end) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          move.goto_next_end(val[1], "textobjects")
        end, { desc = val[2] })
      end
      for key, val in pairs(move_prev_start) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          move.goto_previous_start(val[1], "textobjects")
        end, { desc = val[2] })
      end
      for key, val in pairs(move_prev_end) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          move.goto_previous_end(val[1], "textobjects")
        end, { desc = val[2] })
      end

      -- Scope and fold moves (from locals.scm / folds.scm)
      vim.keymap.set({ "n", "x", "o" }, "]s", function()
        move.goto_next_start("@local.scope", "locals")
      end, { desc = "Next [s]cope" })
      vim.keymap.set({ "n", "x", "o" }, "]z", function()
        move.goto_next_start("@fold", "folds")
      end, { desc = "Next fold" })

      -- ===== Repeatable moves with ; and , =====
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

      -- Make builtin f, F, t, T repeatable with ; and ,
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

      -- Make gitsigns hunk navigation repeatable
      local gs = require("gitsigns")
      local next_hunk = ts_repeat_move.make_repeatable_move(function(opts)
        if opts.forward then
          gs.nav_hunk("next")
        else
          gs.nav_hunk("prev")
        end
      end)
      vim.keymap.set({ "n", "x", "o" }, "]h", function()
        next_hunk({ forward = true })
      end, { desc = "Next git [h]unk" })
      vim.keymap.set({ "n", "x", "o" }, "[h", function()
        next_hunk({ forward = false })
      end, { desc = "Previous git [h]unk" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        mode = "cursor",
      })

      vim.keymap.set("n", "<leader>us", "<cmd>TSContext toggle<CR>", { desc = "Toggle TS Context [S]ticky headers" })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter" },
    opts = {},
  },
  {
    -- when a string above contains the name of the language or the string contains a comment with the language name
    "dariuscorvus/tree-sitter-language-injection.nvim",
    opts = {},
  },
}
