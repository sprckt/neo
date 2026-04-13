# Plan: Disable auto-save plugin

## Problem
The `auto-save.nvim` plugin saves on every text change and insert leave, which is unwanted. The built-in `autowriteall` (save on buffer switch) should be kept.

## Cause
The `auto-save.nvim` plugin in `lua/plugins/autosave.lua` triggers saves on `InsertLeave` and `TextChanged` events.

## Changes Required

### Delete `lua/plugins/autosave.lua`
Remove this file entirely to disable the `auto-save.nvim` plugin.

## Verification
1. Restart Neovim
2. `:Lazy` — confirm `auto-save.nvim` no longer appears
3. Edit a file, wait a moment — confirm the buffer shows `[+]` (unsaved) until you manually save or switch buffers
4. `:set autowriteall?` — should still report `autowriteall`

## Rollback
Restore `lua/plugins/autosave.lua` with:
```lua
return {
  "pocco81/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    trigger_events = { "InsertLeave", "TextChanged" },
  },
}
```
