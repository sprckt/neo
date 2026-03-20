# Python Development Shortcuts Setup

## Overview
Fix `<leader>rr` to reuse a single terminal, add test runner keymaps, and add venv-selector plugin.

## Action Items

- [ ] **1. Fix `<leader>rr` — reuse terminal via Snacks**

  **File:** `lua/config/keymaps.lua` (lines 29-33)

  Replace the current implementation:

  ```lua
  -- Run current python file
  vim.keymap.set("n", "<leader>rr", function()
    local file = vim.fn.expand("%:p")
    vim.cmd("split | terminal uv run " .. file)
  end, { desc = "Run Python file" })
  ```

  With:

  ```lua
  -- Single reusable terminal for running Python files
  local python_term = nil

  vim.keymap.set("n", "<leader>rr", function()
    local file = vim.fn.expand("%:p")
    local cmd = "uv run " .. file
    -- Close existing terminal if open
    if python_term and python_term:buf_valid() then
      python_term:close()
      python_term = nil
    end
    python_term = Snacks.terminal.open(cmd, {
      win = { position = "bottom", height = 0.3 },
      interactive = false,
      auto_close = false,
    })
  end, { desc = "Run Python file" })
  ```

  **Why:** Uses a single `python_term` variable to track the terminal. Closes previous terminal before opening a new one — no duplicate splits. Uses `open()` not `toggle()` so each press always re-runs. Bottom position at 30% height.

- [ ] **2. Add test runner shortcuts**

  **File:** `lua/config/keymaps.lua` (append after the `<leader>rr` block)

  ```lua
  vim.keymap.set("n", "<leader>rt", function()
    require("neotest").run.run()
  end, { desc = "Run nearest test" })

  vim.keymap.set("n", "<leader>rf", function()
    require("neotest").run.run(vim.fn.expand("%"))
  end, { desc = "Run test file" })

  vim.keymap.set("n", "<leader>ro", function()
    require("neotest").output_panel.toggle()
  end, { desc = "Toggle test output" })
  ```

  **Why:** Uses the already-installed neotest from `test.core` extra. No new plugins needed.

- [ ] **3. Add venv-selector plugin**

  **File:** `lua/plugins/python.lua` (new file)

  ```lua
  return {
    -- Better virtual env detection & auto-switching
    { "linux-cultist/venv-selector.nvim", branch = "regexp",
      dependencies = { "neovim/nvim-lspconfig" },
      cmd = "VenvSelect",
      keys = { { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select Virtualenv" } },
      opts = {} },
  }
  ```

  **Why:** Automatically finds and activates Python venvs (uv, poetry, conda, etc.) so your LSP resolves imports correctly. Triggered on-demand with `<leader>cv`.

## Verification

1. Open a `.py` file, press `<leader>rr` — terminal opens at bottom and runs file
2. Press `<leader>rr` again — previous terminal closes, new one opens (no duplicate splits)
3. Press `<leader>rt` on a test function — neotest runs that test
4. Press `<leader>rf` on a test file — neotest runs all tests in file
5. Run `:VenvSelect` — should list available venvs
6. Run `:Lazy` — no errors
