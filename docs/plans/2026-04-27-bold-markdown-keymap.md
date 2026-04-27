# Plan: Bold (`**…**`) markdown keymap

## Problem

Want a quick way to wrap text in Markdown bold (`**word**`):

- A single word under the cursor
- Multiple words (visual selection)
- Any arbitrary visual selection

Single-`*` (italic) is easy via `mini.surround` defaults, but `**` (two-char
delimiter) is awkward.

## Approach

Add a single `<leader>mB` mapping that does the right thing in both modes,
scoped to markdown buffers:

| Mode   | Behaviour                                              |
| ------ | ------------------------------------------------------ |
| Normal | Wrap the word under the cursor (`<cword>`) in `**…**`  |
| Visual | Wrap the current selection in `**…**`                  |

Capital `B` (vs lower-case `b`) keeps it visually associated with **B**old and
avoids collision with the existing `<leader>mb` page-break mapping just added.

### Implementation choice

Use the classic Vim "change + paste from unnamed register" idiom rather than
hand-rolling buffer manipulation:

- Visual: `c**<C-r>"**<Esc>` — cut selection, type `**`, paste, type `**`
- Normal: `ciw**<C-r>"**<Esc>` — same but operating on the inner-word text object

Pros:

- Tiny, no helper function
- Plays nicely with undo (single change unit per invocation)
- Cursor lands just after the closing `**` in normal mode, ready to keep typing

Trade-off: the unnamed register (`""`) is clobbered for that op. That's
standard Vim behaviour for any change/delete and matches what users expect.

### Why not `mini.surround`?

`mini.surround` is already enabled (LazyVim extra) and could be extended with a
custom surround character, but:

1. The mapping prefix differs between LazyVim versions, so documenting "press
   `gsaiwB`" is fragile.
2. The user explicitly asked for **a keymap**.
3. A dedicated `<leader>mB` is discoverable via `which-key` under the existing
   "Markdown Comments" group.

If you later want the motion-based form too (e.g. `saiwB`), we can add a
`custom_surroundings` entry — happy to follow up.

### Why markdown-only

`**bold**` is only meaningful in Markdown. Same `FileType markdown` autocmd
pattern used for `<leader>mb` keeps the mapping scoped.

## Changes Required

### `lua/config/keymaps.lua`

Extend the existing markdown-only autocmd block (added for `<leader>mb`) so
the same `FileType markdown` callback registers both keys. Replace this block:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "<leader>mb", insert_page_break, {
      buffer = args.buf,
      desc = "Insert page break",
    })
  end,
})
```

with:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "<leader>mb", insert_page_break,
      vim.tbl_extend("force", opts, { desc = "Insert page break" }))
    vim.keymap.set("n", "<leader>mB", 'ciw**<C-r>"**<Esc>',
      vim.tbl_extend("force", opts, { desc = "Bold word" }))
    vim.keymap.set("x", "<leader>mB", 'c**<C-r>"**<Esc>',
      vim.tbl_extend("force", opts, { desc = "Bold selection" }))
  end,
})
```

No `which-key` group changes needed — `<leader>m` is already registered.

## Verification

1. Open a `.md` file.
2. Place cursor anywhere on a word, press `<leader>mB` in normal mode →
   word becomes `**word**`, cursor sits just after the closing `**`.
3. Visually select a phrase (`v` then motion, or `V` for line), press
   `<leader>mB` → selection becomes `**phrase**`.
4. Open a non-markdown file → `<leader>mB` should be unmapped.
5. Confirm `<leader>mb` (page break) still works.

## Rollback

Restore the previous single-keymap form of the `FileType markdown` autocmd in
`lua/config/keymaps.lua` (revert the block shown above).
