# Plan: Fix `<leader>mS` placing closing `**` on the next line

## Problem

The `<leader>mS` mapping (bold inner sentence) puts the closing `**` on the
line _after_ the sentence's last word, instead of immediately after that word.

Example, cursor on "Hello":

```markdown
Hello world.
```

Current result:

```markdown
**Hello world.
**
```

Wanted result:

```markdown
**Hello world.**
```

## Cause

The current mapping is:

```
cis**<C-r>"**<Esc>
```

When the inner-sentence text object terminates at end-of-line, the unnamed
register populated by `cis` ends with a trailing newline (`\n`). The paste
step `<C-r>"` re-inserts that newline, so the `**` typed _after_ the paste
lands on the next line.

The word-bold mapping `<leader>mB` (`ciw**<C-r>"**<Esc>`) doesn't hit this
because `iw` never crosses a line boundary.

## Approach

Strip the trailing newline at paste-time by switching from plain register
paste to expression-register paste:

```
cis**<C-r>=substitute(@", "\n$", "", "")<CR>**<Esc>
```

`<C-r>=…<CR>` evaluates the VimScript expression and inserts the result.
`substitute(@", "\n$", "", "")` returns the unnamed register's contents with
exactly one trailing `\n` removed (no-op if there isn't one), so:

- Single-line sentence at end-of-line → `\n` stripped, closing `**` lands on
  the same line.
- Sentence followed by another sentence on the same line → no `\n` to strip,
  behaviour unchanged.

Why not strip _all_ trailing whitespace (`\_s\+$`)? That would also eat
intentional trailing spaces (rare in a sentence body, but Markdown gives
trailing-double-space a meaning — hard line break). Keep the fix minimal:
strip only the unwanted newline.

## Changes Required

### `lua/config/keymaps.lua`

Replace the `<leader>mS` mapping inside the `FileType markdown` autocmd:

```lua
vim.keymap.set(
  "n",
  "<leader>mS",
  [[cis**<C-r>=substitute(@", "\n$", "", "")<CR>**<Esc>]],
  vim.tbl_extend("force", opts, { desc = "Bold sentence" })
)
```

(The Lua `[[…]]` long-bracket string avoids quote-escaping noise.)

No other mappings change.

## Verification

1. Open a `.md` file, paste:

   ```markdown
   Hello world.
   Second line stays put.

   First sentence. Second sentence here. Third one.
   ```

2. Cursor on "Hello", `<leader>mS` → `**Hello world.**` on a single line;
   "Second line stays put." unchanged on the line below.
3. Cursor on "Second" (in the multi-sentence line), `<leader>mS` →
   `First sentence. **Second sentence here.** Third one.` (existing good
   behaviour preserved).
4. Cursor on "Third", `<leader>mS` (last sentence on its line) →
   `First sentence. Second sentence here. **Third one.**` with no stray
   newline.
5. `<leader>mB` and `<leader>mb` continue to work.

## Rollback

Revert the `<leader>mS` mapping to:

```lua
'cis**<C-r>"**<Esc>'
```
