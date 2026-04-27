# Plan: Page-break insertion shortcut

## Problem

Need a quick way to insert a Markdown page break for print/PDF rendering:

```html
<div class="page-break"></div>
```

…followed by an empty line below it.

## Approach

Add a normal-mode keymap `<leader>mb` ("markdown break") that inserts two
lines **below** the current line:

1. `<div class="page-break"></div> ` (note the trailing space, as requested)
2. an empty line

Cursor lands on the empty line in normal mode, ready for the next paragraph.

### Why a keymap (not a true snippet)

The config already uses `<leader>m*` keymaps for the analogous markdown helpers
(`<leader>mt` TODO, `<leader>mn` NOTE, `<leader>ma` AI in
`lua/config/keymaps.lua:16-24`). Following that convention keeps things
consistent and avoids pulling in a separate snippet engine config.

### Why markdown-only

The construct is only meaningful in Markdown. Scoping the mapping with
`buffer = true` via a `FileType markdown` autocmd avoids polluting `<leader>mb`
in unrelated filetypes.

## Changes Required

### `lua/config/keymaps.lua`

Add a helper and a buffer-local keymap registered on the markdown filetype.
Place it near the other markdown helpers (after the existing
`insert_comment` block, around line 24):

```lua
-- Insert a page-break div followed by an empty line below the current line
local function insert_page_break()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, {
    '<div class="page-break"></div> ',
    "",
  })
  vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
end

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

No changes needed to the `which-key` group registration — the existing
`<leader>m` group ("Markdown Comments") will pick the new mapping up
automatically.

## Verification

1. Open any `.md` file.
2. Place cursor on a line, press `<leader>mb` in normal mode.
3. Confirm two new lines appear directly below: the `<div …></div> ` line and a
   blank line, with the cursor on the blank line.
4. Open a non-markdown file (e.g. a `.lua` file) and confirm `<leader>mb`
   does **not** trigger the insertion (buffer-local scope).

## Rollback

Delete the `insert_page_break` function and the `nvim_create_autocmd` block
added in `lua/config/keymaps.lua`.
