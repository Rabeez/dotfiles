return {
    {
        "gbprod/substitute.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        config = function()
            local substitute = require("substitute")
            substitute.setup()

            -- TODO: 's' seems to be mapped to something else. Fix this
            vim.keymap.set("n", "s", substitute.operator, { desc = "Substitute with motion" })
            vim.keymap.set("n", "ss", substitute.line, { desc = "Substitute line" })
            vim.keymap.set("n", "S", substitute.eol, { desc = "Substitute to end of line" })
            vim.keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
        end
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvim-surround").setup({
                -- NOTE: default keymaps
                -- add     ->  ys{motion}{char}
                -- delete  ->  ds{char}
                -- change  ->  cs{target}{replacement}
            })
        end
    }
}
