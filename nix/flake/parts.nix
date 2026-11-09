{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.flakeModules.home-manager # flake.homeModules, flake.homeConfigurations
  ];

  systems = ["x86_64-linux" "aarch64-linux"];

  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };

  # Downstream NixOS imports this one module: every home-manager feature below.
  # Features are all off until `dotfiles.<name>.enable` is set.
  flake.homeModules.default.imports = lib.attrValues (removeAttrs config.flake.homeModules ["default"]);
}
