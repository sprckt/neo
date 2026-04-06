return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night",
    on_highlights = function(hl)
      hl.WinSeparator = { fg = "#ff8700", bold = true }
    end,
  },
}
