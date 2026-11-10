# direnv activates projects from .envrc; `use mise` there loads mise.toml (tools
# and [env]) through direnv's mise integration, so mise's own shell hook is off.
# Secrets: declare a sops template for the project in the host config, e.g.
#   sops.templates."myproject.env".content = "DB_PASSWORD=${config.sops.placeholder.FIRV_PASSWORD}";
# and in .envrc: dotenv ~/.config/sops-nix/secrets/rendered/myproject.env
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
