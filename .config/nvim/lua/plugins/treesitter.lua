return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag"
    },
    config = function()
        local config = require("nvim-treesitter.configs")
        config.setup({
            ensure_installed = { "lua", "vim", "vimdoc", "javascript", "html", "css", "python", "rust", "go", "bash", "json", "ini", "yaml", "toml", "markdown", "sql", "gitignore" },
            sync_install = false,
            auto_install = true,
            autotag = { enable = true, },
            highlight = { enable = true, },
            indent = { enable = true, },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    -- TODO: decrement doesnt work properly
                    node_decremental = "<C-BS>",
                }
            }
        })
    end
}
