local opt = vim.opt

opt.swapfile = false

opt.termguicolors = true
opt.relativenumber = true
opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.mouse = "a"
opt.showmode = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
-- Adjust the view to create some padding near the bottom of the file
-- https://www.reddit.com/r/neovim/comments/17eomi1/how_do_you_deal_with_vertical_scrolloff_not_being/
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("ScrollOffEOF", {}),
	callback = function()
		local win_h = vim.api.nvim_win_get_height(0)
		local off = math.min(vim.o.scrolloff, math.floor(win_h / 2))
		local dist = vim.fn.line("$") - vim.fn.line(".")
		local rem = vim.fn.line("w$") - vim.fn.line("w0") + 1
		if dist < off and win_h - rem + dist < off then
			local view = vim.fn.winsaveview()
			view.topline = view.topline + off - (win_h - rem + dist)
			vim.fn.winrestview(view)
		end
	end,
})

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.backspace = "indent,eol,start"

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Attempt to make imgmagick luarock installation work
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 80 })
	end,
})

-- NOTE: This is max size of harpoon quick-access list
-- used to define keymaps etc dynamically
vim.g.harpoon_max_files = 5

-- Much faster wait time for CursoHold autocmds
vim.o.updatetime = 250

-- Custom filetype overrides
vim.filetype.add({
	extension = {
		jinja = "jinja",
		jinja2 = "jinja",
		j2 = "jinja",
	},
})
