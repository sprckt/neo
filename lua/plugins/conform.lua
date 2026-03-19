-- ~/.config/nvim/lua/plugins/conform.lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "isort", "ruff_format" },
    },
  },
}
