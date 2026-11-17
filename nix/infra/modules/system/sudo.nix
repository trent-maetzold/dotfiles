# Passwordless sudo for wheel.
{config, ...}: let
  modules.nixos.security.sudo.wheelNeedsPassword = false;
in {
  # Flake Modules
  flake.modules.nixos.sudo = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.sudo];
}
