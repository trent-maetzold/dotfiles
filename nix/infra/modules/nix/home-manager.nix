# Home Manager: inside NixOS, sharing its pkgs; and a home under /home with
# ~/.local/bin on PATH.
{
  config,
  home-manager,
  ...
}: let
  modules.homeManager = {config, ...}: {
    home = {
      homeDirectory = "/home/${config.home.username}";
      sessionPath = ["${config.home.homeDirectory}/.local/bin"];
    };
  };

  modules.nixos = {
    imports = [home-manager.nixosModules.home-manager];

    home-manager = {
      backupFileExtension = "backup";
      overwriteBackup = true;
      sharedModules = [config.flake.modules.homeManager.state-version];
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.home-manager = modules.homeManager;
  flake.modules.nixos.home-manager = modules.nixos;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.home-manager];
  flake.homeModules.default-slim.imports = [config.flake.modules.homeManager.home-manager];

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.home-manager];
}
