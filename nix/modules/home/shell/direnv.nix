# Project env: mise.toml (tools and [env]) through mise's own shell hook; direnv
# stays for .envrc files (nix-direnv's `use flake`). mise deprecated `use mise`.
# Secrets: a project fnox.toml; run commands with `fnox exec -- <cmd>`.
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.mise.enable = true;
}
