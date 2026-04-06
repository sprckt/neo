# Lua for LazyVim

A practical introduction to Lua focused on what you need to know for configuring Neovim and LazyVim. This isn't a complete Lua reference — it covers the patterns you'll encounter daily.

## Part 1: Lua Basics

### Variables

```lua
-- Local variables (preferred — scoped to current block/file)
local name = "hello"
local count = 42
local enabled = true
local nothing = nil  -- nil means "no value" / absent

-- Global variables (avoid these in Neovim config — they pollute the namespace)
name = "hello"  -- no 'local' keyword = global
```

**Rule of thumb**: always use `local` in your config files. The only globals you'll set intentionally are `vim.g.*` options.

### Strings

```lua
local single = 'hello'
local double = "hello"        -- single and double quotes are identical
local multi = [[
  This is a
  multi-line string
]]
local joined = "hello" .. " " .. "world"  -- concatenation uses ..
```

### Numbers

```lua
local x = 10
local y = 3.14
local result = x + y    -- 13.14
local integer = x % 3   -- 1 (modulo)
```

### Nil

`nil` is Lua's "nothing" value. It's important because:

```lua
local x        -- x is nil (declared but not assigned)
local t = {}
print(t.missing)  -- nil (key doesn't exist)

-- nil is falsy
if not x then
  print("x is nil")
end
```

### Comments

```lua
-- Single line comment

--[[
  Multi-line
  comment
]]
```

## Part 2: Tables

Tables are Lua's only data structure. They serve as arrays, dictionaries, objects, and modules — all in one.

### As Dictionaries (most common in Neovim config)

```lua
local opts = {
  style = "night",
  transparent = false,
}

-- Access values
print(opts.style)         -- "night"
print(opts["style"])      -- "night" (same thing)

-- Add/modify values
opts.dim_inactive = true
opts.style = "storm"

-- Nested tables
local config = {
  ui = {
    border = "rounded",
    icons = { enabled = true },
  },
}
print(config.ui.border)           -- "rounded"
print(config.ui.icons.enabled)    -- true
```

### As Arrays (ordered lists)

```lua
local fruits = { "apple", "banana", "cherry" }

print(fruits[1])    -- "apple" (Lua arrays start at 1, not 0!)
print(#fruits)      -- 3 (length operator)

table.insert(fruits, "date")      -- append
table.remove(fruits, 2)           -- remove index 2 ("banana")
```

### Mixed Tables

```lua
-- This is valid but uncommon in Neovim config
local mixed = {
  "first",              -- [1] = "first"
  "second",             -- [2] = "second"
  name = "example",     -- string key
}
```

### Why Tables Matter for LazyVim

Almost every LazyVim configuration is a table:

```lua
-- A plugin spec is a table
return {
  "author/plugin",
  opts = {},          -- opts is a table
  keys = {},          -- keys is a table
  dependencies = {},  -- dependencies is a table
}
```

## Part 3: Functions

### Basic Functions

```lua
-- Named function
local function greet(name)
  return "hello " .. name
end

-- Anonymous function (very common in Neovim config)
local greet = function(name)
  return "hello " .. name
end

-- Both forms are equivalent
print(greet("world"))  -- "hello world"
```

### Functions as Arguments (Callbacks)

This pattern appears everywhere in Neovim configuration:

```lua
-- A function passed to another function
vim.keymap.set("n", "<leader>h", function()
  print("hello!")
end)

-- An autocmd callback
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    -- do something before saving
  end,
})
```

### Multiple Return Values

```lua
local function get_position()
  return 10, 20
end

local x, y = get_position()  -- x=10, y=20
```

### Varargs

```lua
local function log(...)
  local args = { ... }
  print(table.concat(args, " "))
end

log("error:", "something broke")  -- "error: something broke"
```

## Part 4: Control Flow

### If/Elseif/Else

```lua
local filetype = "python"

if filetype == "python" then
  print("snake language")
elseif filetype == "lua" then
  print("moon language")
else
  print("something else")
end
```

### Truthiness

```lua
-- Only nil and false are falsy. Everything else is truthy.
if 0 then print("0 is truthy!") end         -- prints! (unlike Python/JS)
if "" then print("empty string is truthy!") end  -- prints!
if nil then print("nil") else print("nil is falsy") end  -- "nil is falsy"
```

This catches people out coming from other languages. `0` and `""` are **truthy** in Lua.

### Logical Operators

```lua
-- and / or / not (not && || !)
if enabled and count > 0 then end
if not enabled or count == 0 then end

-- Short-circuit idiom (like ternary in other languages)
local value = something or "default"     -- use "default" if something is nil/false
local result = flag and "yes" or "no"    -- poor man's ternary
```

### For Loops

```lua
-- Numeric for
for i = 1, 10 do
  print(i)
end

for i = 10, 1, -1 do  -- count down (start, end, step)
  print(i)
end

-- Iterate over array
local items = { "a", "b", "c" }
for i, value in ipairs(items) do
  print(i, value)   -- 1 "a", 2 "b", 3 "c"
end

-- Iterate over dictionary
local opts = { style = "night", transparent = false }
for key, value in pairs(opts) do
  print(key, value)  -- order not guaranteed
end
```

**`ipairs`** = iterate array part (integer keys, in order, stops at first nil)
**`pairs`** = iterate everything (all keys, unordered)

## Part 5: Modules and Require

### How `require` Works

```lua
-- require("foo.bar") looks for:
--   lua/foo/bar.lua
--   lua/foo/bar/init.lua

local lualine = require("lualine")
lualine.setup({ options = { theme = "auto" } })
```

### Creating a Module

```lua
-- lua/plugins/my-plugin.lua
-- Whatever you return from the file IS the module

return {
  "author/plugin-name",
  opts = {},
}
```

This is why every plugin file starts with `return` — the file is a module and lazy.nvim requires it to get the plugin spec.

### Module Caching

Lua caches `require()` results. The first `require("foo")` runs the file; subsequent calls return the cached result. This is why Neovim config changes need a restart — the modules are already cached.

## Part 6: Neovim's Lua API

### The `vim` Global

Neovim exposes everything through the `vim` global table:

```lua
vim.opt       -- Vim options (the Lua way)
vim.g         -- Global variables
vim.b         -- Buffer-local variables
vim.fn        -- Call Vimscript functions
vim.api       -- Neovim API functions
vim.keymap    -- Keymap functions
vim.cmd       -- Execute Vim commands
vim.notify    -- Show notifications
```

### Setting Options (`vim.opt`)

```lua
-- vim.opt wraps :set
vim.opt.number = true            -- :set number
vim.opt.textwidth = 90           -- :set textwidth=90
vim.opt.spelllang = "en_gb"      -- :set spelllang=en_gb

-- List-like options
vim.opt.wildignore:append("*.pyc")    -- add to list
vim.opt.shortmess:append("I")         -- add flag

-- Check current value
print(vim.opt.textwidth:get())   -- 90
```

### Global Variables (`vim.g`)

```lua
-- vim.g sets g: variables (used by many plugins and LazyVim)
vim.g.mapleader = " "           -- let g:mapleader = " "
vim.g.autoformat = true         -- LazyVim uses this to toggle autoformat
vim.g.lazyvim_python_lsp = "basedpyright"  -- tell LazyVim which Python LSP
```

### Calling Vim Functions (`vim.fn`)

```lua
-- vim.fn.{name} calls any Vimscript function
local home = vim.fn.expand("~")
local exists = vim.fn.filereadable("/some/path")
local lines = vim.fn.getline(1, "$")
```

### Running Vim Commands (`vim.cmd`)

```lua
-- Execute any Ex command
vim.cmd("colorscheme tokyonight-night")
vim.cmd.colorscheme("tokyonight-night")   -- structured form (same thing)
vim.cmd("write")
vim.cmd.write()

-- Multi-line
vim.cmd([[
  augroup MyGroup
    autocmd!
    autocmd BufRead *.md setlocal wrap
  augroup END
]])
```

### Keymaps (`vim.keymap.set`)

```lua
vim.keymap.set(
  "n",                    -- mode: n=normal, i=insert, v=visual, x=visual-only
  "<leader>rr",           -- key sequence
  function()              -- action (string or function)
    vim.cmd("split | terminal uv run " .. vim.fn.expand("%"))
  end,
  { desc = "Run Python file", silent = true }  -- options
)
```

**Modes**: `"n"` normal, `"i"` insert, `"v"` visual+select, `"x"` visual only, `"t"` terminal, `""` all modes

### Autocommands (`vim.api.nvim_create_autocmd`)

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    -- runs before saving any .lua file
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
```

Common events: `BufRead`, `BufWritePre`, `BufWritePost`, `FileType`, `ColorScheme`, `VimEnter`, `LspAttach`

### Highlight Groups (`vim.api.nvim_set_hl`)

```lua
vim.api.nvim_set_hl(0, "WinSeparator", {
  fg = "#ff8700",
  bold = true,
})

-- 0 means global namespace
-- Other options: bg, italic, underline, link (to another group)
```

## Part 7: LazyVim Plugin Spec Patterns

### The Basic Spec

```lua
return {
  "author/plugin-name",   -- [1] the plugin source (GitHub shorthand)
}
```

### Common Spec Keys

```lua
return {
  "author/plugin-name",

  -- Loading control
  lazy = false,           -- load at startup (default for custom plugins)
  event = "BufRead",      -- lazy-load on event
  cmd = "MyCommand",      -- lazy-load when command is run
  ft = "python",          -- lazy-load for filetype
  keys = {                -- lazy-load on keypress + define mapping
    { "<leader>t", "<cmd>MyCommand<cr>", desc = "My thing" },
  },

  -- Configuration
  opts = {},              -- passed to plugin.setup(opts), deep-merged across specs
  config = function()     -- replaces default setup — use sparingly
    require("plugin").setup({})
  end,

  -- Dependencies
  dependencies = {
    "other/plugin",
  },

  -- Control
  enabled = true,         -- set false to disable
  priority = 1000,        -- load order (higher = earlier, default 50)
}
```

### `opts` — Declarative Configuration

```lua
-- This is the preferred way to configure plugins
return {
  "folke/tokyonight.nvim",
  opts = {
    style = "night",
    transparent = false,
  },
}
```

Behind the scenes, lazy.nvim calls `require("tokyonight").setup(opts)`. If multiple specs target the same plugin, their `opts` tables are **deep-merged**.

### `opts` as a Function

When you need to modify opts based on the defaults rather than replacing:

```lua
return {
  "some/plugin",
  opts = function(_, opts)
    -- opts contains the merged options so far
    table.insert(opts.sources, "extra-source")
    opts.special = true
    return opts
  end,
}
```

### `config` — Imperative Configuration

```lua
-- Takes full control — opts won't be auto-applied
return {
  "some/plugin",
  config = function(_, opts)
    -- opts is still available if you want it
    require("some-plugin").setup(opts)
    -- plus any extra imperative setup
    vim.cmd("echo 'loaded!'")
  end,
}
```

**When to use `config` over `opts`**: only when you need to run additional code after setup, or when the plugin doesn't follow the standard `.setup()` pattern.

### Multiple Specs in One File

```lua
-- lua/plugins/ui.lua
return {
  -- First plugin
  {
    "plugin/one",
    opts = {},
  },
  -- Second plugin
  {
    "plugin/two",
    opts = {},
  },
}
```

### Lazy-loading Patterns

```lua
-- Load when a command is used
{ "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit" } }

-- Load for specific filetypes
{ "rust-lang/rust.vim", ft = "rust" }

-- Load on keypress
{
  "author/plugin",
  keys = {
    { "<leader>t", function() require("plugin").toggle() end, desc = "Toggle" },
  },
}

-- Load on event
{ "author/plugin", event = "BufReadPost" }
-- Common events for lazy-loading:
--   "VeryLazy"    — after startup (good default)
--   "BufReadPost" — when a buffer is read
--   "InsertEnter" — when entering insert mode
```

## Part 8: Common Patterns in Neovim Config

### Conditional Logic

```lua
-- Do something only for a specific filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
  end,
})

-- Platform-specific config
if vim.fn.has("mac") == 1 then
  -- macOS specific
end
```

### Safe Requiring

```lua
-- Avoid errors if a plugin isn't installed
local ok, plugin = pcall(require, "some-plugin")
if ok then
  plugin.setup({})
end
```

`pcall` (protected call) catches errors and returns `false` instead of crashing.

### String Formatting

```lua
local msg = string.format("Found %d files in %s", count, path)
-- or
local msg = ("Found %d files in %s"):format(count, path)
```

### Inspecting Values (Debugging)

```lua
-- Print a table's contents (invaluable for debugging config)
print(vim.inspect(some_table))

-- Or use vim.notify for a popup
vim.notify(vim.inspect(some_table))

-- In Neovim 0.9+, shorthand:
vim.print(some_table)
```

### Checking if a Plugin is Available

```lua
-- LazyVim helper to check if a plugin is loaded
if LazyVim.has("plugin-name") then
  -- do something
end

-- Or check lazy.nvim directly
local has_plugin = require("lazy.core.config").spec.plugins["plugin-name"] ~= nil
```

## Quick Reference Card

| Lua | Python/JS equivalent | Notes |
|-----|---------------------|-------|
| `local x = 1` | `x = 1` / `let x = 1` | Always use `local` |
| `..` | `+` / `+` | String concatenation |
| `~=` | `!=` / `!==` | Not equal |
| `#t` | `len(t)` / `t.length` | Length of array |
| `t[1]` | `t[0]` / `t[0]` | Arrays start at 1 |
| `and or not` | `and or not` / `&& \|\| !` | Logical operators |
| `nil` | `None` / `null` | Absence of value |
| `{}` | `{}` / `{}` | Table (dict AND array) |
| `pairs(t)` | `t.items()` / `Object.entries(t)` | Iterate all keys |
| `ipairs(t)` | `enumerate(t)` / `t.forEach()` | Iterate array part |
| `require("x")` | `import x` / `require("x")` | Module import |
| `pcall(fn)` | `try/except` / `try/catch` | Protected call |
| `function() end` | `lambda:` / `() => {}` | Anonymous function |
