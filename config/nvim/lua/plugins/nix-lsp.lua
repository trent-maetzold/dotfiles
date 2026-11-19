return {
  -- LazyVim enables configured servers via vim.lsp when this bridge is disabled.
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  -- Keep Mason for formatters/debuggers without shadowing Nix-provided servers.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.PATH = "append"
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return vim.fn.executable(tool) == 0
      end, opts.ensure_installed)
    end,
  },
}
