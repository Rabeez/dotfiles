return {
	"vhyrro/luarocks.nvim",
	priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config
	-- brew install luarocks
	--    brew install luajit
	--    luarocks --local --lua-version 5.1 install magick
	--    brew install pkg-config
	opts = {
		rocks = { "magick" },
	},
}
