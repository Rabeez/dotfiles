return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    init = function()
      vim.o.foldcolumn = "0" -- no native fold column (no numbers)
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.signcolumn = "yes:1" -- fixed 1-sign width, separate from fold arrow
      vim.opt.fillchars:append({ eob = "~", fold = "" })

      -- Custom statuscolumn: clickable fold arrow | signs | line number
      vim.o.statuscolumn = table.concat({
        "%@v:lua.FoldClickHandler@",
        "%{%",
        "'%#FoldColumn#'..",
        "(foldlevel(v:lnum)>foldlevel(v:lnum-1)?",
        "(foldclosed(v:lnum)==-1?'':''):",
        "'  ')",
        "%}",
        "%X",
        "%s", -- signs (diagnostics, gitsigns) in their own column
        "%l ", -- line number
      })

      -- Click handler for fold arrows in statuscolumn
      _G.FoldClickHandler = function(_, _, _, _)
        local line = vim.fn.getmousepos().line
        if vim.fn.foldlevel(line) > vim.fn.foldlevel(line - 1) then
          vim.api.nvim_win_set_cursor(0, { line, 0 })
          vim.cmd("normal! za")
        end
      end
    end,
    opts = {
      provider_selector = function(_, filetype, _)
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local fillChar = ""
        local suffix = (" %d lines "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local curWidth = 0

        local maxTextWidth = math.floor(width * 0.4)
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if maxTextWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, maxTextWidth - curWidth)
            table.insert(newVirtText, { chunkText, chunk[2] })
            curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
            break
          end
          curWidth = curWidth + chunkWidth
        end

        local fillWidth = width - curWidth - sufWidth
        if fillWidth > 1 then
          table.insert(newVirtText, { " " .. fillChar:rep(fillWidth - 1), "Comment" })
        end

        table.insert(newVirtText, { suffix, "UfoFoldedEllipsis" })
        return newVirtText
      end,
    },
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
      {
        "zr",
        function()
          require("ufo").openFoldsExceptKinds()
        end,
        desc = "Open folds except kinds",
      },
      {
        "zm",
        function()
          require("ufo").closeFoldsWith()
        end,
        desc = "Close folds with",
      },
      {
        "zp",
        function()
          require("ufo").peekFoldedLinesUnderCursor()
        end,
        desc = "Peek fold",
      },
    },
  },
}
