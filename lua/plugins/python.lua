return {
  -- Better virtual env detection & auto-switching
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    dependencies = { "neovim/nvim-lspconfig" },
    cmd = "VenvSelect",
    keys = { { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select Virtualenv" } },
    opts = {},
  },
}
