# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Neovim configuration built on [LazyVim](https://www.lazyvim.org/) v8. LazyVim provides the base plugin set and keymaps; this config layers custom plugins, keymaps, and options on top.

## Your Role

You are a Neovim configuration assistant. **Never make changes directly** — always create a plan first.

## Rules

- **All plans must be created as markdown files under `docs/plans/`**
- Plans should be named: `YYYY-MM-DD-<description>.md` (e.g. `2026-03-20-fix-copilot.md`)
- Wait for explicit approval before applying any changes
- When diagnosing errors, ask for the full error message and relevant config first
- Prefer minimal, targeted changes over large rewrites
- Always explain _why_ a change is needed, not just _what_ to change

### Plan Format

```markdown
# Plan: <title>

## Problem
What is wrong or what is being added.

## Cause
Why the problem is happening (for fixes).

## Changes Required
### <filename>
\`\`\`lua
-- code here
\`\`\`

## Verification
How to confirm the change worked.

## Rollback
How to undo if something goes wrong.
```

## Architecture

LazyVim convention: `lua/config/` files are auto-loaded by LazyVim at specific lifecycle points. `lua/plugins/` files each return a lazy.nvim plugin spec and are auto-imported via `{ import = "plugins" }` in `lazy.lua`.

### Key files

| File | Purpose |
|------|---------|
| `lua/config/lazy.lua` | Bootstraps lazy.nvim, imports LazyVim + `plugins/` dir |
| `lua/config/options.lua` | Vim options (wrap, textwidth=90, colorcolumn, UK spelling) |
| `lua/config/keymaps.lua` | Custom keymaps (markdown comment insertion, Python runner) |
| `lua/config/autocmds.lua` | Custom autocommands (currently empty) |
| `lazyvim.json` | Declares enabled LazyVim extras (keep alphabetical) |

### Notable plugin overrides

| Plugin file | What it customizes |
|---|---|
| `plugins/blink.lua` | Disables completion entirely in markdown files |
| `plugins/colourscheme.lua` | Molokai colorscheme (fallback: habamax) |
| `plugins/conform.lua` | Python formatting: isort then ruff_format |
| `plugins/mine.lua` | Markdown formatting: prettier with `--prose-wrap always --print-width 90` |
| `plugins/copilot.lua` | Disables Copilot suggestions in markdown files |
| `plugins/lint.lua` | markdownlint-cli2 with custom config at `plugins/cfg_linters/` |
| `plugins/snacks.lua` | Explorer shows hidden/ignored files |

### Custom keymaps (`lua/config/keymaps.lua`)

| Key | Action |
|-----|--------|
| `<leader>rr` | Run current Python file with `uv run` in a split terminal |
| `<leader>mf` | Insert `<!-- FIXME:  -->` at cursor |
| `<leader>mt` | Insert `<!-- TODO:  -->` at cursor |
| `<leader>mn` | Insert `<!-- NOTE:  -->` at cursor |
| `<leader>ma` | Insert `<!-- AI:  -->` at cursor |

## Enabled LazyVim Extras

From `lazyvim.json` — **AI**: copilot, copilot-chat · **Coding**: mini-surround · **DAP**: core · **Formatting**: prettier · **Lang**: docker, git, markdown, nix, python, sql, svelte, tailwind, terraform, toml, typescript, vue, yaml · **Test**: core (neotest) · **UI**: mini-animate, treesitter-context · **Util**: dot, gh, mini-hipatterns

## Conventions

- **Python**: uses `uv` for running files and managing venvs
- **Spelling**: `en_gb`, user dict at `spell/en.utf-8.add`, project dict at `project.utf-8.add` (relative to cwd)
- **Markdown comments**: use `<!-- TAG: message -->` format for agent review passes
- **Text width**: 90 columns with visible colorcolumn
- **Autoformat**: enabled globally (`vim.g.autoformat = true`)

## Common Tasks

- **Add a plugin**: Create `lua/plugins/<name>.lua`, restart Neovim, `:Lazy sync`
- **Add a LazyVim extra**: Add to `lazyvim.json` `"extras"` array (keep alphabetical)
- **Add a keymap**: Add to `lua/config/keymaps.lua` using `vim.keymap.set`
- **Check plugin status**: `:Lazy`
- **Check LSP status**: `<leader>cl`
- **Check Mason packages**: `<leader>cm`

## Diagnostics Checklist

When reporting an error, provide:
1. The full error message (`:MasonLog` or `:Lazy log <plugin>`)
2. The relevant plugin config file contents
3. What you were doing when the error occurred
4. Output of `:Lazy` filtered to the relevant plugin
