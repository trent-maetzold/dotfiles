# Starship prompt: one line, green or red ❯ by exit status.
{config, ...}: let
  modules.homeManager = {
    programs.starship = {
      enable = true;

      settings = {
        add_newline = false;
        character.success_symbol = "[❯](bold green)";
        character.error_symbol = "[❯](bold red)";
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.starship = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.starship];
  flake.homeModules.default-slim.imports = [config.flake.modules.homeManager.starship];
}
