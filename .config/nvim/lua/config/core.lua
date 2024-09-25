local opt = vim.opt

opt.termguicolors = true
opt.relativenumber = true
opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true
