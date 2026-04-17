# Plan: Fix autosave on buffer switch

## Problem

Files are not saved when moving to another buffer, despite
`vim.opt.autowriteall = true` being set in `lua/config/options.lua` with the
comment _"covers all buffer-switch scenarios"_.

## Cause

`autowriteall` does **not** actually cover all buffer-switch scenarios. Per
`:help autowrite` / `:help autowriteall`, it only fires on a fixed set of
commands:

- `:next`, `:previous`, `:last`, `:first`, `:rewind`, `:tag`
- `:!`, `:make`, `:suspend`, `:stop`
- `:buffer N`, `CTRL-^`, `CTRL-]`, `CTRL-O`, `CTRL-I`, jumps to `'{A-Z0-9}`
- (autowriteall only) `:edit`, `:enew`, `:quit`, `:qall`, `:xit`, `:exit`,
  `:recover`, closing the window

Crucially, the common ways LazyVim users switch buffers are **not** in that
list:

- `:bnext` / `:bprev` / `:bn` / `:bp` (and `<S-h>` / `<S-l>` keymaps that wrap
  them)
- Window navigation: `<C-w>h/j/k/l/w`, and jumping windows via Snacks picker
- Clicking a tab in `bufferline.nvim`

So the buffer stays `[+]` dirty when you `<S-l>` to the next buffer. That
matches what you're seeing.

Since `auto-save.nvim` was removed in `1da9084`, nothing else picks up the
slack.

## Changes Required

Add a `BufLeave` + `FocusLost` autocmd that writes modified, real,
modifiable, named buffers. Keep `autowriteall = true` — it remains useful for
`:make`, `:!`, `:edit`, `<C-^>`, etc., and the autocmd handles the rest. Fix
the misleading comment too.

### `lua/config/autocmds.lua`

```lua
-- Autosave: write the buffer we are leaving, and on focus-lost.
-- `autowriteall` (set in options.lua) does NOT fire on :bnext/:bprev or
-- window navigation, so we need this autocmd to cover those cases.
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("user_autosave", { clear = true }),
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    if bo.buftype ~= "" then return end          -- skip terminals, help, etc.
    if not bo.modifiable or bo.readonly then return end
    if not bo.modified then return end
    if vim.api.nvim_buf_get_name(ev.buf) == "" then return end
    vim.api.nvim_buf_call(ev.buf, function()
      vim.cmd("silent! lockmarks update")
    end)
  end,
})
```

Notes on the implementation:

- `update` writes only if modified (cheaper than unconditional `write`);
  `silent!` avoids the "written" echo on every switch; `lockmarks` prevents
  `'[` / `']` being clobbered.
- `nvim_buf_call` runs the write against the buffer being left, not the one
  you just switched to (important on `BufLeave`).
- The `buftype ~= ""` guard excludes `terminal`, `nofile`, `help`, `quickfix`,
  `prompt` — all of which would error or misbehave on write.

### `lua/config/options.lua`

Fix the comment so future-you isn't misled:

```lua
-- Autosave on :edit, :next, :!, :make, <C-^>, etc. Buffer/window switches
-- (:bnext, <C-w>l, bufferline clicks) are handled by the BufLeave autocmd
-- in autocmds.lua — autowriteall does NOT cover those.
vim.opt.autowriteall = true
```

## Verification

1. Restart Neovim.
2. Open two files: `nvim lua/config/options.lua lua/config/autocmds.lua`.
3. Edit the first, confirm `[+]` in statusline.
4. `:bnext` (or `<S-l>`) — the `[+]` should disappear on the buffer you left.
5. Edit again, `<C-w>` split and switch windows — same: `[+]` clears.
6. Edit again, alt-tab out of the terminal — on return, buffer is saved.
7. `:set autowriteall?` → still reports `autowriteall`.
8. Open a terminal (`:terminal`), leave it — no errors (buftype guard works).

## Rollback

Delete the `user_autosave` augroup block from `lua/config/autocmds.lua` and
revert the comment in `lua/config/options.lua`.
