# Roblox Studio, run under Wine by Vinegar.
{config, ...}: {
  # Flake Modules
  flake.modules.homeManager.roblox-studio = {pkgs, ...}: {
    home.packages = [pkgs.vinegar];
  };

  # Home Configuration Modules
  flake.homeModules.kids.imports = [config.flake.modules.homeManager.roblox-studio];
}
