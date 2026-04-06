# Plan: Make split window divider more visible

## Problem
The window separator between splits is too subtle with the Molokai colorscheme, making it hard to distinguish split boundaries.

## Cause
Molokai's default `WinSeparator` highlight uses a low-contrast color.

## Changes Required
### `lua/plugins/colourscheme.lua`
Add a `config` function that applies the colorscheme and then overrides the `WinSeparator` highlight:

```lua
return {
  "tomasr/molokai",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("molokai")
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#ff8700", bold = true })
  end,
}
```

This sets the divider to a bold orange (`#ff8700`) that fits the Molokai palette. You can swap the colour — see alternatives below.

### Colour alternatives
| Colour | Hex | Vibe |
|--------|-----|------|
| Orange | `#ff8700` | On-theme, warm |
| Blue | `#66d9ef` | Molokai's existing blue |
| Green | `#a6e22e` | High contrast |
| White | `#ffffff` | Maximum visibility |

## Verification
1. Restart Neovim
2. Open a split: `:vsplit` or `<C-w>v`
3. The divider line should now be the chosen colour and bold

## Rollback
Remove the `config` function and revert to the original 5-line spec.
