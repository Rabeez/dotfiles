return {
  {
    "jellydn/my-note.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      {
        "<leader>un",
        "<cmd>MyNote<cr>",
        desc = "Open [n]ote",
      },
    },
    opts = {
      files = {
        -- Using the parent .git folder as the current working directory
        cwd = function()
          local bufPath = vim.api.nvim_buf_get_name(0)
          local cwd = require("lspconfig").util.root_pattern(".git")(bufPath)

          return cwd
        end,
      },
    },
  },
  -- {
  --   "epwalsh/obsidian.nvim",
  --   version = "*",
  --   lazy = true,
  --   -- Load obsidian.nvim for markdown files in vault only
  --   event = {
  --     "BufReadPre " .. vim.fn.expand("~") .. "/Documents/Obsidian/Main/*.md",
  --     "BufNewFile " .. vim.fn.expand("~") .. "/Documents/Obsidian/Main/*.md",
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "hrsh7th/nvim-cmp",
  --     "nvim-telescope/telescope.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   opts = {
  --     -- disable_frontmatter = true,
  --     ui = { enable = false },
  --     workspaces = {
  --       {
  --         name = "Main",
  --         path = "~/Documents/Obsidian/Main",
  --       },
  --     },
  --     templates = {
  --       folder = "my-templates-folder",
  --       date_format = "%Y-%m-%d-%a",
  --       time_format = "%H:%M",
  --     },
  --     mappings = {
  --       -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
  --       ["gf"] = {
  --         action = function()
  --           return require("obsidian").util.gf_passthrough()
  --         end,
  --         opts = { noremap = false, expr = true, buffer = true },
  --       },
  --       -- Smart action depending on context, either follow link or toggle checkbox.
  --       ["<cr>"] = {
  --         action = function()
  --           return require("obsidian").util.smart_action()
  --         end,
  --         opts = { buffer = true, expr = true },
  --       },
  --     },
  --     note_frontmatter_func = function(note)
  --       local bufnr = vim.api.nvim_get_current_buf()
  --       local function extract_frontmatter(bufnr)
  --         local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  --         if #lines < 3 or lines[1] ~= "---" then
  --           return nil
  --         end
  --         local fm = {}
  --         local i = 2
  --         while i <= #lines and lines[i] ~= "---" do
  --           local key, value = lines[i]:match("^(%w+):%s*(.+)$")
  --           if key and value then
  --             fm[key] = value
  --           end
  --           i = i + 1
  --         end
  --         return fm
  --       end
  --       local existing = extract_frontmatter(bufnr)
  --       if existing then
  --         return existing
  --       end
  --       if note.title and not vim.tbl_contains(note.aliases, note.title) then
  --         note:add_alias(note.title)
  --       end
  --       return {
  --         id = note.id,
  --         aliases = note.aliases or {},
  --         tags = note.tags or {},
  --       }
  --     end,
  --     -- -- Optional, customize how note file names are generated given the ID, target directory, and title.
  --     -- ---@param spec { id: string, dir: obsidian.Path, title: string|? }
  --     -- ---@return string|obsidian.Path The full path to the new note.
  --     -- note_path_func = function(spec)
  --     --   -- This is equivalent to the default behavior.
  --     --   local path = spec.dir / tostring(spec.id) .. "_" .. tostring(spec.title)
  --     --   return path:with_suffix(".md")
  --     -- end,
  --   },
  -- },
}
