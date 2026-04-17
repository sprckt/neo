# Plan: Replace isort with ruff_organize_imports

## Problem
Ruff flags unsorted import blocks because isort and ruff disagree on import ordering. Running two separate tools for import sorting causes conflicts.

## Cause
`isort` and `ruff` have different default rules for import ordering. When isort sorts first, ruff may still consider the result "unsorted" by its own rules.

## Changes Required
### `lua/plugins/conform.lua`
```lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "ruff_organize_imports", "ruff_format" },
    },
  },
}
```

Replace `"isort"` with `"ruff_organize_imports"` so ruff handles both import sorting and formatting with consistent rules.

## Verification
1. Open a Python file with unsorted imports
2. Save the file (triggers autoformat)
3. Run `:ConformInfo` — should show `ruff_organize_imports` and `ruff_format` as available
4. Confirm no more "unsorted imports" warnings from ruff

## Rollback
Revert `conform.lua` to use `"isort"` instead of `"ruff_organize_imports"`.
