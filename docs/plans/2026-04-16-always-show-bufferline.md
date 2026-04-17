# Plan: Always show bufferline + auto-save on buffer switch

## Problem
1. When only one buffer is open, the tabline (snacks bufferline) hides. This means the green circle that indicates unsaved changes is not visible, making it hard to tell if the file needs saving.
2. Navigating away from a buffer with unsaved changes does not automatically save it. LazyVim sets `autowrite` by default, which covers some commands (`:edit`, `:next`) but not all buffer-switch actions (e.g. `<leader>bd`, `:bnext`, snacks picker navigation).

## Cause
1. LazyVim's `bufferline.nvim` config sets `always_show_bufferline = false`, which hides the tabline when there's only one buffer. Setting `showtabline = 2` in options doesn't help because bufferline manages the tabline visibility itself.
2. `autowriteall` is not set. Only `autowrite` is enabled (LazyVim default), which doesn't cover all buffer-leave scenarios.

## Changes Required
### New file: `lua/plugins/bufferline.lua`
Override the LazyVim default to always show bufferline:
```lua
return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = true,
    },
  },
}
```

### `lua/config/options.lua`
Add:
```lua
-- Auto-save when navigating away from a buffer (covers all buffer-switch scenarios)
vim.opt.autowriteall = true
```

## Verification
1. Open Neovim with a single file: `nvim somefile.lua`
2. Confirm the bufferline is visible at the top
3. Make a change — the green modified indicator should appear
4. Save with `:w` — the indicator should disappear
5. Open a second buffer and confirm it still works as before
6. Make a change in the current buffer, then switch to another buffer (`:bnext` or `<leader>,`) — confirm the change was auto-saved (no `[+]` when you switch back)
7. `:set autowriteall?` — should report `autowriteall`

## Rollback
- Delete `lua/plugins/bufferline.lua`
- Remove the `vim.opt.autowriteall = true` line from `lua/config/options.lua`
