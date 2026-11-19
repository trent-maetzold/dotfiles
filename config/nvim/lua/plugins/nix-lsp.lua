return {
  {
    "neovim/nvim-lspconfig",
    -- LazyVim passes these to vim.lsp.config and skips the Mason installs.
    opts = {
      servers = {
        marksman = { mason = false },
        omnisharp = { mason = false },
        r_language_server = { mason = false },
      },
    },
  },
}
