# The flake's one stateVersion, in each default profile.
{config, ...}: let
  stateVersion = "26.11";
  modules.homeManager.home = {inherit stateVersion;};
  modules.nixos.system = {inherit stateVersion;};
in {
  # Flake Modules
  flake.modules.homeManager.state-version = modules.homeManager;
  flake.modules.nixos.state-version = modules.nixos;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.state-version];

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.state-version];
}
