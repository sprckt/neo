# Fix snacks.nvim Configuration

## Problem - DONE

The current `lua/plugins/snacks.lua` has two issues:

1. `autosave` is not a snacks.nvim module — it's silently ignored
2. `explorer.hidden` and `explorer.ignored` are at the wrong nesting level

## Fix 1: Explorer — Show Hidden/Ignored Files by Default

The top-level `explorer` config only accepts `replace_netrw` and `trash`. The `hidden` and
`ignored` options are **picker-level** settings and must go under
`picker.sources.explorer`.

**Change `lua/plugins/snacks.lua` to:**

```lua
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
```

> **Tip:** You can also toggle these at runtime inside the explorer with `H` (hidden) and
> `I` (ignored).

## Fix 2: Add Auto-Save

snacks.nvim does not have an autosave module. Two options:

### Option A: Simple autocmd (no plugin needed)

Add this to `lua/config/autocmds.lua`:

```lua
-- Auto-save on focus lost or buffer leave
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  callback = function(ev)
    local buf = ev.buf
    if
      vim.bo[buf].modified
      and not vim.bo[buf].readonly
      and vim.fn.expand("%") ~= ""
      and vim.bo[buf].buftype == ""
    then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! write")
      end)
    end
  end,
})
```

### Option B: Dedicated plugin

Add a new file `lua/plugins/autosave.lua`:

```lua
return {
  "okuuuu/auto-save.nvim",
  event = { "FocusLost", "BufLeave" },
  opts = {},
}
```

Then run `:Lazy sync` to install.

## Verification

1. Restart Neovim (or `:Lazy sync`)
2. Run `:Lazy` — confirm no errors on snacks.nvim
3. Open explorer (`:lua Snacks.explorer()`) — dotfiles/hidden files should be visible
4. If you added autosave: edit a file, switch buffers, and confirm it saved (no `[+]`
   modified indicator)
