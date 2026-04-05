-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function insert_comment(tag)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local before = line:sub(1, col)
  local after = line:sub(col + 1)
  local comment = "<!-- " .. tag .. ":  -->"
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before .. comment .. after })
  vim.api.nvim_win_set_cursor(0, { row, col + #tag + 7 })
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>mt", function()
  insert_comment("TODO")
end, { desc = "Insert TODO comment" })
vim.keymap.set("n", "<leader>mn", function()
  insert_comment("NOTE")
end, { desc = "Insert NOTE comment" })
vim.keymap.set("n", "<leader>ma", function()
  insert_comment("AI")
end, { desc = "Insert AI comment" })

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

-- Python testing shortcuts
vim.keymap.set("n", "<leader>rt", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>rf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })

vim.keymap.set("n", "<leader>ro", function()
  require("neotest").output_panel.toggle()
end, { desc = "Toggle test output" })

-- Paste clipboard image into Markdown
local function paste_image()
  -- Default: current file's directory + timestamp filename
  local default_dir = vim.fn.expand("%:p:h")
  local default_name = os.date("screenshot-%Y%m%d-%H%M%S.png")

  vim.ui.input({
    prompt = "Save image to: ",
    default = default_dir .. "/" .. default_name,
    completion = "file",
  }, function(input)
    if not input or input == "" then
      return
    end

    -- Create parent directory if it doesn't exist
    local dir = vim.fn.fnamemodify(input, ":h")
    vim.fn.mkdir(dir, "p")

    -- Try pngpaste (brew install pngpaste), fall back to osascript
    local ok
    if vim.fn.executable("pngpaste") == 1 then
      ok = os.execute("pngpaste " .. vim.fn.shellescape(input)) == 0
    else
      local script =
        string.format('tell application "System Events" to write (the clipboard as PNG) to (POSIX file "%s")', input)
      ok = os.execute("osascript -e " .. vim.fn.shellescape(script)) == 0
    end

    if ok then
      -- Insert relative path markdown reference at cursor
      local rel = vim.fn.fnamemodify(input, ":~:.")
      local md = string.format("![image](%s)", rel)
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line:sub(1, col) .. md .. line:sub(col + 1) })
      vim.api.nvim_win_set_cursor(0, { row, col + #md })
      vim.notify("Saved: " .. input, vim.log.levels.INFO)
    else
      vim.notify("No image in clipboard (or pngpaste/osascript unavailable)", vim.log.levels.WARN)
    end
  end)
end

vim.keymap.set("n", "<leader>pi", paste_image, { desc = "Paste clipboard image" })

-- Register keygroups
require("which-key").add({
  { "<leader>m", group = "Markdown Comments", icon = "📝" },
  { "<leader>r", group = "Run/Test", icon = "🧪" },
  { "<leader>p", group = "Paste", icon = "📋" },
})
