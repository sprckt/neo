# Plan: Exclude ShellCheck SC2034 for .env/.envrc files

## Problem
ShellCheck warning SC2034 ("variable appears unused") fires on `.env` and `.envrc` files where variables are defined for sourcing, not direct use.

## Cause
The `util.dot` LazyVim extra runs shellcheck on shell filetypes. Variables in `.env`/`.envrc` are exported by sourcing, so they appear "unused" to shellcheck.

## Changes Required

### `lua/plugins/lint.lua`
Add a shellcheck linter override that dynamically appends `--exclude=SC2034` when the current buffer filename matches `.env*` or `.envrc`.

```lua
["shellcheck"] = {
  args = function()
    local filename = vim.fn.expand("%:t")
    local base_args = { "--format", "json", "-" }
    if filename:match("^%.env") or filename == ".envrc" then
      return { "--exclude=SC2034", "--format", "json", "-" }
    end
    return base_args
  end,
},
```

## Verification
1. Open a `.env` or `.envrc` file — SC2034 should not appear
2. Open a regular `.sh` file with an unused variable — SC2034 should still appear
3. Other shellcheck warnings should still work in all files

## Rollback
Remove the `["shellcheck"]` block from `lua/plugins/lint.lua`.
