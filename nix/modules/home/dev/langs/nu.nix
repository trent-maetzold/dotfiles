# Nushell scripts: nufmt formatter (the LSP is `nu --lsp`, set up by mason).
{pkgs, ...}: {
  home.packages = [pkgs.nufmt];
}
