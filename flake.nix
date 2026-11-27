{
  description = "Zoldt's NixOS and Home Manager Flake";

  outputs = inputs: import ./outputs inputs;

  inputs = {
    # Core
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    import-tree.url = "github:denful/import-tree";

    # Hosts and system services
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    # GitOps: standalone hosts pull this repo and switch themselves.
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zoldt-pkgs = {
      url = "github:zoldt/packages.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zoldt-infra.url = "git+ssh://git@github.com/zoldt/.infra.nix.git";
    zoldt-agents = {
      url = "github:zoldt/agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zoldt-pkgs.follows = "zoldt-pkgs";
    };
    zoldt-secrets = {
      url = "github:zoldt/secrets.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zoldt-dotfiles.url = "github:zoldt/dotfiles.nix";
    secrets = {
      url = "git+ssh://git@github.com/zoldt/.secrets.git?exportIgnore=1";
      flake = false;
    };

    # Imported host services and storage.
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Shared module inputs
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Umbriel compositor; cachix tracks the latest commit CI cached, and no
    # nixpkgs follow so those store paths match (its installation guide).
    umbriel.url = "github:noctalia-dev/umbriel/cachix";

    # Packages
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    # Noctalia community plugins, available for runtime plugin configuration.
    noctalia-plugins = {
      url = "github:noctalia-dev/community-plugins";
      flake = false;
    };
  };
}
