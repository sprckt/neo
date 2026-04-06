# Plan: Switch colorscheme to tokyonight-night

## Problem
Want to change colorscheme from Molokai to tokyonight-night.

## Cause
Preference change. tokyonight is already installed (LazyVim dependency), so no new plugin needed.

## Changes Required

### `lua/plugins/colourscheme.lua`
Replace Molokai with tokyonight configuration:

```lua
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night",
  },
}
```

### `lua/config/lazy.lua`
Update the fallback colorscheme list (line 34):

```lua
install = { colorscheme = { "tokyonight-night", "habamax" } },
```

## Verification
1. Restart Neovim
2. Run `:colorscheme` — should show `tokyonight-night`
3. Verify colours look correct across splits, statusline, and syntax highlighting

## Rollback
Revert both files to reference `molokai` instead of `tokyonight-night`.
