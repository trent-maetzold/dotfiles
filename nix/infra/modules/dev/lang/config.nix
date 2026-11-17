# LSPs and formatters for config files: nix, bash, yaml, toml, json, markdown,
# docker.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      alejandra
      bash-language-server
      docker-compose-language-service
      dockerfile-language-server
      markdown-toc
      markdownlint-cli2
      marksman
      nil
      prettier
      shellcheck
      shfmt
      statix
      taplo
      vscode-langservers-extracted
      yaml-language-server
    ];

    programs.lazyvim.extras.lang = {
      docker.enable = true;
      git.enable = true;
      json.enable = true;
      markdown.enable = true;
      nix.enable = true;
      sql.enable = true;
      toml.enable = true;
      yaml.enable = true;
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.lang-config = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.lang-config];
}
