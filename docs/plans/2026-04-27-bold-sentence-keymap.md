# Plan: Bold-sentence markdown keymap

## Problem

The new `<leader>mB` mapping bolds a single word (normal) or a visual
selection. Want a third variant: bold the **sentence** under the cursor with
one keystroke, without having to enter visual mode and pick the bounds by
hand.

## Approach

Add `<leader>mS` ("markdown Sentence-bold") in normal mode, scoped to
markdown buffers. Uses Vim's built-in `is` (inner-sentence) text object so
sentence bounds follow Vim's normal rules (`.`, `!`, `?` followed by
whitespace / newline — see `:h sentence`).

Implementation mirrors the existing word-bold mapping, swapping `iw` → `is`:

```
cis**<C-r>"**<Esc>
```

| Key             | Mode   | Target                          |
| --------------- | ------ | ------------------------------- |
| `<leader>mB`    | normal | word under cursor               |
| `<leader>mB`    | visual | selection                       |
| `<leader>mS`    | normal | sentence under cursor (**new**) |

### Naming choice

Two viable options:

1. **`<leader>mS`** (chosen) — capital S = "Sentence". Smallest change; no
   collision with the existing `<leader>mB` chord.
2. **Reorg `<leader>mB` into a prefix** (`<leader>mBw` word, `<leader>mBs`
   sentence). More consistent ("B = Bold + target") but turns the day-old
   word-bold mapping into 3 keystrokes and adds a which-key timeout to the
   visual-mode `<leader>mB`.

Going with option 1 for minimal disruption. If you'd prefer option 2 later,
easy follow-up.

### Why markdown-only

`**bold**` is markdown syntax. Same `FileType markdown` autocmd already used
for `<leader>mb` and `<leader>mB`.

## Changes Required

### `lua/config/keymaps.lua`

Inside the existing `FileType markdown` autocmd callback (the block that sets
`<leader>mb`, `<leader>mB` normal, `<leader>mB` visual), append one more
mapping:

```lua
vim.keymap.set(
  "n",
  "<leader>mS",
  'cis**<C-r>"**<Esc>',
  vim.tbl_extend("force", opts, { desc = "Bold sentence" })
)
```

No other edits.

## Verification

1. Open a `.md` file containing a multi-sentence paragraph.
2. Place cursor anywhere inside one sentence, press `<leader>mS`.
3. Confirm only that sentence becomes `**…**` — surrounding sentences
   untouched, trailing whitespace preserved outside the `**`.
4. Confirm `<leader>mB` (word / selection) and `<leader>mb` (page break) still
   behave as before.
5. Open a non-markdown file → `<leader>mS` is unmapped.

### Sentence-boundary sanity check

Test buffer:

```markdown
First sentence. Second sentence here. Third one.
```

Cursor on "Second" → `<leader>mS` should yield:

```markdown
First sentence. **Second sentence here.** Third one.
```

If Vim's sentence detection feels off (e.g. abbreviations like "e.g.")
that's a `:h sentence` quirk, not a bug in the mapping.

## Rollback

Delete the `<leader>mS` `vim.keymap.set` call added inside the `FileType
markdown` autocmd in `lua/config/keymaps.lua`.
