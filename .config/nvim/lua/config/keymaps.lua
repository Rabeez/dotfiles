-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set({ "n", "v" }, "<space>", "<NOP>")
vim.keymap.set({ "n", "v" }, "<CR>", "<NOP>")

-- Black-hole register for character deletion
vim.keymap.set("n", "x", '"_x')

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- vim.keymap.set("n", "<C-h>", "<C-w><C-H>", { desc = "Move focus to the left window" })
-- vim.keymap.set("n", "<C-l>", "<C-w><C-L>", { desc = "Move focus to the right window" })
-- vim.keymap.set("n", "<C-j>", "<C-w><C-J>", { desc = "Move focus to the lower window" })
-- vim.keymap.set("n", "<C-k>", "<C-w><C-K>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "[t", "<cmd>bprevious<CR>", { desc = "Go to previous buffer/[t]ab" })
vim.keymap.set("n", "]t", "<cmd>bnext<CR>", { desc = "Go to next buffer/[t]ab" })

-- TODO:
-- ]]/[[ to move to end/start of current scope (use treesitter??)
-- alternate: perform visual selection e.g. vim (select inside function/method, then press o to go to beginning/end of selection)

-- Preserve yank buffer after paste
-- vim.keymap.set("n", "p", "pgvy")

vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page [u]p and center cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page [d]p and center cursor" })

vim.keymap.set("n", "U", "<cmd>redo<CR>", { desc = "Redo" })

vim.keymap.set("n", "<C-p>", "o<ESC>p", { desc = "[p]aste in next line" })
