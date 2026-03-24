return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      markdown = { "markdownlint-cli2" },
    },
    linters = {
      ["shellcheck"] = {
        args = function()
          local filename = vim.fn.expand("%:t")
          if filename:match("^%.env") or filename == ".envrc" then
            return { "--exclude=SC2034", "--format", "json", "-" }
          end
          return { "--format", "json", "-" }
        end,
      },
      ["markdownlint-cli2"] = {
        args = {
          "--config",
          vim.fn.stdpath("config") .. "/lua/plugins/cfg_linters/global.markdownlint-cli2.yaml",
          "--",
        },
      },
    },
  },
}
