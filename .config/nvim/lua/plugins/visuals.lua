return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end
    },
    -- TODO: this doesn't seem to work for renaming in neotree
    {
        'stevearc/dressing.nvim',
        -- event = "VeryLazy",
        config = function()
            require("dressing").setup()
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPre", "BufNewFile" },
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
        config = function()
            -- TODO: make this a dimmer grey color
            require("ibl").setup({
                -- char_highlight_list = { "#9ca0b0" }
            })
        end
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local lazy_status = require("lazy.status")
            require('lualine').setup({
                sections = {
                    lualine_x = {
                        {
                            lazy_status.updates,
                            cond = lazy_status.has_updates
                        }
                    }
                }
            })
        end
    }
}
