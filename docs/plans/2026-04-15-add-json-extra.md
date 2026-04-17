# Plan: Add JSON formatting support

## Problem
Formatting a JSON file shows "no formatter available". The LazyVim `formatting.prettier` extra sets up prettier for JSON, but the custom conform overrides in `conform.lua` and `mine.lua` overwrite `formatters_by_ft`, losing the JSON mapping.

## Cause
Both `plugins/conform.lua` and `plugins/mine.lua` set `formatters_by_ft` via `opts`, which overwrites the table from the LazyVim extra instead of merging into it. JSON ends up with no formatter.

## Changes Required
### `lua/plugins/conform.lua`
Add `json` to `formatters_by_ft`:

```lua
-- ~/.config/nvim/lua/plugins/conform.lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      json = { "prettier" },
      python = { "ruff_organize_imports", "ruff_format" },
    },
  },
}
```

## Verification
1. Restart Neovim
2. Open a minified/messy JSON file
3. Save (or run `:ConformInfo` to confirm prettier is listed for JSON)
4. The file should be formatted with proper indentation

## Rollback
Remove the `json = { "prettier" },` line from `conform.lua`.
