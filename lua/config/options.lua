-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Adds a wrap here
vim.opt.wrap = true
vim.opt.textwidth = 90
vim.opt.colorcolumn = "90"

-- Dictionary details
vim.opt.spelllang = { "en_gb" } -- UK English
vim.opt.spellfile = {
  vim.fn.expand("~/.config/nvim/spell/en.utf-8.add"), -- user dictionary
  vim.fn.expand("project.utf-8.add"), -- project dictionary (relative to cwd)
}
