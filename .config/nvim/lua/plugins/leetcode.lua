return {
	{
		"kawre/leetcode.nvim",
		build = ":TSUpdate html",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim", -- required by telescope
			"MunifTanjim/nui.nvim",

			-- optional
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		---@alias lc.lang
		---| "cpp"
		---| "java"
		---| "python"
		---| "python3"
		---| "c"
		---| "csharp"
		---| "javascript"
		---| "typescript"
		---| "php"
		---| "swift"
		---| "kotlin"
		---| "dart"
		---| "golang"
		---| "ruby"
		---| "scala"
		---| "rust"
		---| "racket"
		---| "erlang"
		---| "elixir"
		---| "bash"
		opts = {
			---@type string
			arg = "leet",

			---@type lc.lang
			lang = "python3",
		},
	},
}
