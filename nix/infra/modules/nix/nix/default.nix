# Nix with flakes, nh, comma, nix-ld and nix-index.
{
  config,
  nix-index-database,
  ...
}: let
  inherit (config) flake;

  modules.nixos = {pkgs, ...}: {
    imports = [nix-index-database.nixosModules.nix-index];

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
      trusted-users = ["@wheel"];
    };

    nixpkgs.overlays = builtins.attrValues flake.overlays;

    programs = {
      nh.enable = true;
      nix-index-database.comma.enable = true;

      nix-ld = {
        enable = true;
        libraries = [pkgs.stdenv.cc.cc.lib];
      };
    };
  };

  modules.homeManager = {
    config,
    lib,
    pkgs,
    flakePath,
    ...
  }: {
    imports = [nix-index-database.homeModules.nix-index];

    agents.md.tools = ["- `nx`: run something that isn't installed, via `nix shell nixpkgs#...`: `nx jq ripgrep -- jq --version`. Packages before `--`, command after; without `--` it opens a shell."];

    # A script, not an alias, so non-interactive agent shells get it.
    home.packages = [pkgs.nx];

    programs = {
      nh = {
        enable = true;
        flake = flakePath;
      };

      nix-index-database.comma.enable = true;

      nix-init = {
        enable = true;

        settings = {
          commit = true;
          access-tokens."github.com".command = lib.mkIf config.programs.gh.enable ["gh" "auth" "token"];
        };
      };

      nix-search-tv.enable = true;
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.nix = modules.nixos;
  flake.modules.homeManager.nix = modules.homeManager;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.nix];

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.nix];
  flake.homeModules.default-slim.imports = [config.flake.modules.homeManager.nix];
}
