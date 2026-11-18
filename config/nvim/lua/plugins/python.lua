return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = { mason = false, cmd = { "ty", "server" } },
      },
    },
  },
}
