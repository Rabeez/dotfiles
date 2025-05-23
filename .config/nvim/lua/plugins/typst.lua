return {
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {},
    config = function()
      require("typst-preview").setup({
        dependencies_bin = { ["tinymist"] = "tinymist" },
      })
    end,
  },
}
