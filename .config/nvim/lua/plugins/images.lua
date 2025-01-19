return {
  -- {
  -- 	"3rd/image.nvim",
  -- 	version = "1.1.0",
  -- 	config = function()
  -- 		require("image").setup({
  -- 			backend = "kitty",
  -- 			integrations = {
  -- 				markdown = {
  -- 					enabled = true,
  -- 					clear_in_insert_mode = false,
  -- 					download_remote_images = true,
  -- 					only_render_image_at_cursor = false,
  -- 					filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
  -- 				},
  -- 				neorg = {
  -- 					enabled = true,
  -- 					clear_in_insert_mode = false,
  -- 					download_remote_images = true,
  -- 					only_render_image_at_cursor = false,
  -- 					filetypes = { "norg" },
  -- 				},
  -- 				html = {
  -- 					enabled = false,
  -- 				},
  -- 				css = {
  -- 					enabled = false,
  -- 				},
  -- 			},
  -- 			max_width = 100,
  -- 			max_height = 50,
  -- 			max_width_window_percentage = math.huge, -- this is necessary for a good experience
  -- 			max_height_window_percentage = math.huge,
  -- 			window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
  -- 			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  -- 			-- editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
  -- 			-- tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
  -- 			-- hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
  -- 		})
  -- 	end,
  -- },
  {
    "willothy/wezterm.nvim",
    config = function()
      -- TODO: set these keymaps up in a way that they don't conflict with nvim native pane switching
      -- similar to nvim tmux navigator
      -- CHECK OUT THIS PLUGIN
      -- https://github.com/mrjones2014/smart-splits.nvim
      -- vim.keymap.set("n", "<leader>wt", require("wezterm").switch_pane_direction)
    end,
  },
}
