return {
	{
		"folke/lazydev.nvim",
		dependencies = {
			"justinsgithub/wezterm-types",
		},
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- always load the LazyVim library
				"LazyVim",
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				-- Load the wezterm types when the `wezterm` module is required
				-- Needs `justinsgithub/wezterm-types` to be installed
				{ path = "wezterm-types", mods = { "wezterm" } },
			},
			enabled = function(root_dir)
				-- always enable unless `vim.g.lazydev_enabled = false`
				local a = vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
				-- disable when a .luarc.json file is found
				local b = not vim.uv.fs_stat(root_dir .. "/.luarc.json")
				return a or b
			end,
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
}
