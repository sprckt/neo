# Plan: Filter SC2034 from bashls on .env/.envrc files

## Problem
SC2034 ("variable appears unused") warning shows on `.env`/`.envrc` files from bashls's embedded shellcheck.

## Cause
bashls runs its own shellcheck internally. Variables in `.env`/`.envrc` are exported by sourcing tools (e.g. direnv), so they appear "unused" to shellcheck.

## Changes Applied
### `lua/plugins/bashls.lua` (new file)
Override bashls's `publishDiagnostics` handler to filter out SC2034 for `.env`/`.envrc` files:

```lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      bashls = {
        handlers = {
          ["textDocument/publishDiagnostics"] = function(err, result, ctx)
            local fname = vim.fn.fnamemodify(vim.uri_to_fname(result.uri), ":t")
            if fname:match("^%.env") or fname == ".envrc" then
              result.diagnostics = vim.tbl_filter(function(d)
                return tostring(d.code) ~= "SC2034"
              end, result.diagnostics)
            end
            vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
          end,
        },
      },
    },
  },
}
```

### `lua/plugins/lint.lua`
Removed unused shellcheck override from nvim-lint. nvim-lint never ran shellcheck (no `sh` entry in `linters_by_ft`), so the config was dead code.

## Verification
1. Open a `.env` or `.envrc` file — SC2034 should not appear
2. Open a regular `.sh` file — SC2034 should still appear for genuinely unused variables
3. Other shellcheck warnings should still work in `.env` files

## Rollback
Delete `lua/plugins/bashls.lua`.
