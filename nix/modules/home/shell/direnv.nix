# direnv activates projects from .envrc; `use mise` there loads mise.toml (tools
# and [env]) through direnv's mise integration, so mise's own shell hook is off.
# Secrets: a project fnox.toml; run commands with `fnox exec -- <cmd>`.
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    mise.enable = true;
  };
  programs.mise = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = false;
  };
}
