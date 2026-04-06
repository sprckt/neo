# Plan: Add WinSeparator highlight override via autocmd

## Problem
The WinSeparator bold orange override was removed when cleaning up colourscheme.lua.

## Changes Required
### `lua/config/autocmds.lua`
Add a `ColorScheme` autocmd that sets the WinSeparator highlight. This approach survives colorscheme switches and doesn't interfere with lazy.nvim's `opts` handling.

```lua
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#ff8700", bold = true })
  end,
})
```

## Verification
1. Restart Neovim
2. `:vsplit` — divider should be bold orange
3. `:colorscheme tokyonight-day` then back to `:colorscheme tokyonight-night` — divider stays orange both times

## Rollback
Remove the autocmd from `lua/config/autocmds.lua`.
