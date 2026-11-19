return {
  -- LazyVim enables configured servers via vim.lsp when this bridge is disabled.
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  -- Keep Mason for formatters/debuggers without shadowing Nix-provided servers.
  { "mason-org/mason.nvim", opts = { PATH = "append" } },
}
