return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VimEnter",
  config = function()
    require("alpha").setup(require("alpha.themes.dashboard").config)
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set header
    -- https://patorjk.com/software/taag/#p=testall&v=0&f=Ghost&t=NEOVIM
    dashboard.section.header.val = {
      "",
      "",
      "",
      "",
      "                                                                                         .         .           ",
      "b.             8 8 8888888888       ,o888888o.  `8.`888b           ,8'  8 8888          ,8.       ,8.          ",
      "888o.          8 8 8888          . 8888     `88. `8.`888b         ,8'   8 8888         ,888.     ,888.         ",
      "Y88888o.       8 8 8888         ,8 8888       `8b `8.`888b       ,8'    8 8888        .`8888.   .`8888.        ",
      ".`Y888888o.    8 8 8888         88 8888        `8b `8.`888b     ,8'     8 8888       ,8.`8888. ,8.`8888.       ",
      "8o. `Y888888o. 8 8 888888888888 88 8888         88  `8.`888b   ,8'      8 8888      ,8'8.`8888,8^8.`8888.      ",
      "8`Y8o. `Y88888o8 8 8888         88 8888         88   `8.`888b ,8'       8 8888     ,8' `8.`8888' `8.`8888.     ",
      "8   `Y8o. `Y8888 8 8888         88 8888        ,8P    `8.`888b8'        8 8888    ,8'   `8.`88'   `8.`8888.    ",
      "8      `Y8o. `Y8 8 8888         `8 8888       ,8P      `8.`888'         8 8888   ,8'     `8.`'     `8.`8888.   ",
      "8         `Y8o.` 8 8888          ` 8888     ,88'        `8.`8'          8 8888  ,8'       `8        `8.`8888.  ",
      "8            `Yo 8 888888888888     `8888888P'           `8.`           8 8888 ,8'         `         `8.`8888. ",
      "",
      "",
      "",
    }

    -- Set menu
    dashboard.section.buttons.val = {}

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function()
        vim.opt_local.foldenable = false
      end,
    })
  end,
}
