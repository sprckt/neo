-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function insert_comment(tag)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local before = line:sub(1, col)
  local after = line:sub(col + 1)
  local comment = "<!-- " .. tag .. ":  -->"
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before .. comment .. after })
  vim.api.nvim_win_set_cursor(0, { row, col + #tag + 7 })
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>mf", function()
  insert_comment("FIXME")
end, { desc = "Insert FIXME comment" })
vim.keymap.set("n", "<leader>mt", function()
  insert_comment("TODO")
end, { desc = "Insert TODO comment" })
vim.keymap.set("n", "<leader>mn", function()
  insert_comment("NOTE")
end, { desc = "Insert NOTE comment" })
vim.keymap.set("n", "<leader>ma", function()
  insert_comment("AI")
end, { desc = "Insert NOTE comment" })
