# LazyVim Guide

## Introduction

LazyVim is a Neovim distribution — a pre-configured layer on top of Neovim that provides sensible defaults, curated plugins, and a structured way to organise your configuration. It's built on [lazy.nvim](https://github.com/folke/lazy.nvim), the plugin manager, but adds opinionated defaults for LSP, formatting, completion, navigation, and more.

The key idea: instead of assembling 40+ plugins yourself and wiring them together, LazyVim gives you a working IDE-like setup out of the box. You then customise by overriding specific parts rather than building from scratch.

LazyVim sits between "vanilla Neovim" (configure everything yourself) and "full IDE" (no customisation). You get the power of a curated setup with the flexibility to change anything.

## Components

### Core Systems

| Component | What it does | Key plugins |
|-----------|-------------|-------------|
| **Plugin Manager** | Installs, loads, and updates plugins | lazy.nvim |
| **LSP** | Language intelligence (go-to-definition, diagnostics, hover) | nvim-lspconfig, mason.nvim |
| **Completion** | Autocomplete with snippets | blink.cmp (or nvim-cmp) |
| **Formatting** | Auto-format on save | conform.nvim |
| **Linting** | Code quality checks beyond LSP | nvim-lint |
| **Treesitter** | Syntax highlighting, text objects, folding | nvim-treesitter |
| **Fuzzy Finder** | Search files, buffers, grep, symbols | Telescope or fzf-lua |

### Navigation & UI

| Component | What it does | Key plugins |
|-----------|-------------|-------------|
| **File Explorer** | Sidebar or floating file tree | neo-tree.nvim or snacks.explorer |
| **Bufferline** | Tab-like bar for open buffers | bufferline.nvim |
| **Statusline** | Bottom bar with mode, branch, diagnostics | lualine.nvim |
| **Dashboard** | Start screen with recent files and shortcuts | snacks.dashboard |
| **Which-Key** | Popup showing available keybindings | which-key.nvim |
| **Notifications** | Non-intrusive message popups | snacks.notifier |

### Editing

| Component | What it does | Key plugins |
|-----------|-------------|-------------|
| **Surround** | Add/change/delete surrounding pairs | mini.surround or nvim-surround |
| **Comments** | Toggle comments with `gc` | built-in (Neovim 0.10+) |
| **Autopairs** | Auto-close brackets, quotes | mini.pairs |
| **Indent Guides** | Visual indentation lines | snacks.indent |
| **Flash/Leap** | Fast cursor movement | flash.nvim |

### Extras

LazyVim "extras" are optional plugin bundles you enable in `lazyvim.json`. They add support for specific languages, tools, or workflows without cluttering the base config. Examples:

- **Language extras**: `lang.python`, `lang.typescript`, `lang.rust` — add LSP, formatter, treesitter grammar, and test runner for a language
- **Tool extras**: `formatting.prettier`, `dap.core` (debugging), `test.core` (neotest)
- **UI extras**: `ui.mini-animate`, `ui.treesitter-context`
- **AI extras**: `ai.copilot`, `ai.copilot-chat`

## How to Configure

### File Structure

LazyVim auto-loads files from two directories:

```
lua/
├── config/          -- Auto-loaded by LazyVim at startup
│   ├── lazy.lua     -- Bootstraps lazy.nvim, defines plugin sources
│   ├── options.lua  -- Vim options (loaded first)
│   ├── keymaps.lua  -- Custom key mappings
│   └── autocmds.lua -- Custom autocommands
└── plugins/         -- Each file returns a lazy.nvim plugin spec
    ├── example.lua  -- Override or add a plugin
    └── ...
```

**Load order**: `options.lua` → `lazy.lua` (plugins install) → `autocmds.lua` → `keymaps.lua`

### Overriding a Plugin

To change a plugin that LazyVim already configures, create a file in `lua/plugins/` that targets the same plugin. lazy.nvim merges specs by plugin name:

```lua
-- lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "vertical",
    },
  },
}
```

You don't need to redefine the entire spec — just the parts you want to change. `opts` tables are deep-merged.

### Disabling a Plugin

```lua
return {
  "plugin/name",
  enabled = false,
}
```

### Adding a New Plugin

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  event = "BufRead",  -- lazy-load trigger
  opts = {},
}
```

### Enabling Extras

Add to the `extras` array in `lazyvim.json` (keep alphabetical):

```json
{
  "extras": [
    "lazyvim.plugins.extras.lang.python",
    "lazyvim.plugins.extras.lang.typescript"
  ]
}
```

Or use `:LazyExtras` to browse and toggle them interactively.

### Setting Vim Options

```lua
-- lua/config/options.lua
vim.opt.wrap = true
vim.opt.textwidth = 90
vim.opt.spelllang = "en_gb"
```

### Adding Keymaps

```lua
-- lua/config/keymaps.lua
vim.keymap.set("n", "<leader>rr", function()
  -- your action
end, { desc = "Run something" })
```

## Tips

### 1. Learn the Leader Key System

LazyVim organises keymaps under `<leader>` (Space by default). Press `<Space>` and wait — which-key shows all available bindings grouped by category:

- `<leader>f` — find/files
- `<leader>s` — search
- `<leader>c` — code actions
- `<leader>g` — git
- `<leader>b` — buffers
- `<leader>u` — UI toggles

### 2. Use `:LazyExtras` Before Writing Config

Before manually adding a language plugin, check if a LazyVim extra already exists for it. Extras handle LSP, formatter, treesitter, and test runner setup in one toggle.

### 3. Check What's Already Mapped

Before adding a keymap, run `:map <leader>x` (replacing `x` with your prefix) to see existing bindings. LazyVim has many keymaps you might not know about.

### 4. Use `opts` Over `config` When Possible

`opts` is declarative and mergeable — multiple specs can contribute to the same plugin's options. `config` is imperative and replaces the default setup entirely. Prefer `opts` unless you need full control.

### 5. Useful Commands

| Command | What it does |
|---------|-------------|
| `:Lazy` | Plugin manager dashboard — install, update, profile |
| `:LazyExtras` | Browse and toggle extras |
| `:Mason` | Manage LSP servers, formatters, linters |
| `:LspInfo` | Show active LSP clients for current buffer |
| `:ConformInfo` | Show active formatters for current buffer |
| `:checkhealth` | Diagnose common issues |

### 6. Read the Source

LazyVim's plugin specs are readable Lua files. When something behaves unexpectedly, check the source:

- Base plugins: `~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/`
- Your overrides: `~/.config/nvim/lua/plugins/`

Your overrides are merged on top of the base specs, so reading both helps you understand the final configuration.

### 7. Profile Startup Time

If Neovim feels slow to start, run `:Lazy profile` to see which plugins take the longest to load. Use lazy-loading triggers (`event`, `cmd`, `keys`, `ft`) to defer plugins you don't need immediately.
