vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

local floating_terminal_win = nil
local floating_terminal_buf = nil
vim.keymap.set("n", "<leader>tt", function()
  -- If the floating window exists and is valid, close it
  if floating_terminal_win ~= nil and vim.api.nvim_win_is_valid(floating_terminal_win) then
    vim.api.nvim_win_close(floating_terminal_win, true)
    floating_terminal_win = nil
  else
    -- If the buffer doesn't exist, create a new terminal buffer
    if floating_terminal_buf == nil or not vim.api.nvim_buf_is_valid(floating_terminal_buf) then
      floating_terminal_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_call(floating_terminal_buf, function()
        vim.fn.termopen(vim.o.shell)
      end)
      vim.api.nvim_set_option_value("bufhidden", "hide", { buf = floating_terminal_buf }) -- Hide buffer when closed
    end

    -- Define the floating window size and position
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Open the floating window
    floating_terminal_win = vim.api.nvim_open_win(floating_terminal_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })

    vim.cmd("startinsert") -- Start in insert mode
  end
end, { desc = "[T]erminal: [T]oggle float term", noremap = true, silent = true })
