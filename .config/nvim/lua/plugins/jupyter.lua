return {
    {
        "meatballs/notebook.nvim",
        config = function()
            require("notebook").setup()
        end
    },
    -- TODO: setup molten to allow for an attached kernel
    -- https://github.com/benlubas/molten-nvim
}
