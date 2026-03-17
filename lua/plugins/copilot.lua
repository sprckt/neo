-- Copilot configuration
return {
  -- Standard copilot
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = {
        markdown = false,
      },
    },
  },
  -- Native copilot
  {
    "github/copilot.vim",
    enabled = false,
  },
}
