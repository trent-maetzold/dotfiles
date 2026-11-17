# Nix authoring tools: nix-tree, nix-diff, nix-init, nurl and friends.
{config, ...}: let
  packages = pkgs: with pkgs; [deadnix nix-diff nix-init nix-output-monitor nix-search-tv nix-tree nix-update nurl];
  modules.nixos = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
  modules.homeManager = {pkgs, ...}: {home.packages = packages pkgs;};
in {
  # Flake Modules
  flake.modules.nixos.pkgs-nix = modules.nixos;
  flake.modules.homeManager.pkgs-nix = modules.homeManager;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.pkgs-nix];

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.pkgs-nix];
}
