# Plan: Add which-key group labels for custom keymap prefixes

## Problem
The `<leader>m`, `<leader>r`, and `<leader>p` prefixes show up without descriptions in the which-key popup, making them harder to discover.

## Cause
LazyVim registers group names for its built-in prefixes, but custom prefixes need explicit registration via `which-key.add()`.

## Changes Required
### `lua/config/keymaps.lua`
Add the following at the end of the file:

```lua
-- Which-key group labels for custom prefixes
require("which-key").add({
  { "<leader>m", group = "Markdown" },
  { "<leader>r", group = "Run/Test" },
  { "<leader>p", group = "Paste" },
})
```

## Verification
1. Restart Neovim
2. Press `<leader>` and wait for which-key popup
3. Confirm `m`, `r`, and `p` now show their group descriptions

## Rollback
Remove the `require("which-key").add(...)` block from `lua/config/keymaps.lua`.
