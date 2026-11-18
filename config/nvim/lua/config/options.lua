-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_python_lsp = "ty"
-- Nix-installed .NET apphosts do not discover runtimes from PATH.
if not vim.env.DOTNET_ROOT and vim.fn.isdirectory(vim.fn.expand("~/.nix-profile/share/dotnet")) == 1 then
  vim.env.DOTNET_ROOT = vim.fn.expand("~/.nix-profile/share/dotnet")
end
