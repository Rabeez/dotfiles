-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set({ "n", "v" }, "<space>", "<NOP>")
-- vim.keymap.set({ "n", "v" }, "<CR>", "<NOP>")

-- Black-hole register for character deletion
vim.keymap.set("n", "x", '"_x')

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("i", "<left>", "<nop>")
vim.keymap.set("i", "<right>", "<nop>")
vim.keymap.set("i", "<up>", "<nop>")
vim.keymap.set("i", "<down>", "<nop>")

-- Keybinds to make split navigation easier.
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- NOTE: Naming (horiz/vert) is same as in wezterm for consistency
vim.api.nvim_set_keymap("n", "<leader>wv", "<cmd>split<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>wh", "<cmd>vsplit<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "[t", "<cmd>bprevious<CR>", { desc = "Go to previous buffer/[t]ab" })
vim.keymap.set("n", "]t", "<cmd>bnext<CR>", { desc = "Go to next buffer/[t]ab" })

-- TODO:
-- ]]/[[ to move to end/start of current scope (use treesitter??)
-- alternate: perform visual selection e.g. vim (select inside function/method, then press o to go to beginning/end of selection)

-- Preserve yank buffer after paste
-- vim.keymap.set("n", "p", "pgvy")

vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page [u]p and center cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page [d]p and center cursor" })
vim.keymap.set("n", "G", "Gzz", { desc = "Goto end-of-file and center cursor" })

vim.keymap.set("n", "U", "<cmd>redo<CR>", { desc = "Redo" })

vim.keymap.set("n", "<C-p>", "o<ESC>p", { desc = "[p]aste in next line" })

vim.keymap.set("n", "<leader>ua", "ggVG", { desc = "Visually select [a]ll" })

-- personalized TODO comment
vim.keymap.set("n", "<leader>un", function()
  local cs = vim.bo.commentstring
  cs = cs:gsub("%%s", ""):gsub("%s+$", "")
  if cs ~= "" then
    cs = cs .. " "
  end

  local todo_line = cs .. "TODO: (rabeez) "
  vim.api.nvim_feedkeys("o" .. todo_line, "n", false)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>A", true, false, true), "n", false)
end, { desc = "Insert TODO comment (rabeez)" })

-- Disable horizontal scroll in all modes
-- default: scrolling enabled
local horizontal_scroll_disabled = false
local scroll_keys = {
  "<ScrollWheelLeft>",
  "<ScrollWheelRight>",
  "<S-ScrollWheelLeft>",
  "<S-ScrollWheelRight>",
}
local function set_horizontal_scroll(disable)
  for _, key in ipairs(scroll_keys) do
    if disable then
      vim.keymap.set({ "n", "v", "i" }, key, "<Nop>", { silent = true })
    else
      pcall(vim.keymap.del, { "n", "v", "i" }, key)
    end
  end
  horizontal_scroll_disabled = disable
end

vim.api.nvim_create_user_command("ToggleScrollWheel", function()
  set_horizontal_scroll(not horizontal_scroll_disabled)
  vim.notify("󰍽 Horizontal Scroll wheel disabled: " .. tostring(horizontal_scroll_disabled))
end, {})
