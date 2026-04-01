return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      bashls = {
        handlers = {
          ["textDocument/publishDiagnostics"] = function(err, result, ctx)
            local fname = vim.fn.fnamemodify(vim.uri_to_fname(result.uri), ":t")
            if fname:match("^%.env") or fname == ".envrc" then
              result.diagnostics = vim.tbl_filter(function(d)
                return tostring(d.code) ~= "SC2034"
              end, result.diagnostics)
            end
            vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
          end,
        },
      },
    },
  },
}
