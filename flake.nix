{
  description = "Home Manager dotfiles";

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    import-tree,
    bkt,
    pyproject-nix,
    uv2nix,
    pyproject-build-systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    systems = ["x86_64-linux" "aarch64-linux"];

    trent = import ./nix/users/trent/identity.nix;
  in {
    # Standalone NixOS configurations.
    nixosConfigurations = {
      muninn = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          user = trent;
        };
        modules = [
          ./nix/hosts/muninn
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [self.overlays.default];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = inputs // {user = trent;};
              users.trent = import ./nix/hosts/muninn/home.nix;
            };
          }
        ];
      };
      nidavellir = nixpkgs.lib.nixosSystem {
        modules = [
          inputs.microvm.nixosModules.microvm
          ./nix/hosts/nidavellir
        ];
      };
      sif = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./nix/hosts/sif];
      };
      heimdall = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./nix/hosts/heimdall];
      };
      yggdrasil = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          user = trent;
        };
        modules = [
          ./nix/hosts/yggdrasil
          home-manager.nixosModules.home-manager
        ];
      };
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    # Local packages as pkgs.<name>; hosts apply this overlay.
    overlays.default = import ./nix/pkgs {inherit bkt uv2nix pyproject-nix pyproject-build-systems;};

    # The overlay's packages, buildable on their own (`nix build .#tredis`).
    packages = lib.genAttrs systems (system:
      lib.filterAttrs (_: lib.isDerivation)
      (builtins.intersectAttrs (self.overlays.default null null)
        (nixpkgs.legacyPackages.${system}.extend self.overlays.default)));

    # Deployment admin tasks (`nix run .#switch`); the justfile wraps each.
    apps = lib.genAttrs systems (system:
      import ./nix/apps {
        pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
        inherit self;
      });

    # Modules take this flake's inputs and `user` as arguments:
    # specialArgs / home-manager.extraSpecialArgs = inputs // {inherit user;}.
    # Every home module except desktop/, which only desktop hosts import.
    homeModules.default = import-tree.filterNot (lib.hasInfix "/desktop/") ./nix/modules/home;
    homeModules.desktop = import-tree ./nix/modules/home/desktop;
    # nix/modules/nixos is grouped. Standalone hosts import machine, desktop,
    # hardware and deploy modules by path; `default` bundles common, services
    # and wsl for WSL hosts.
    nixosModules.default = import-tree [
      ./nix/modules/nixos/common
      ./nix/modules/nixos/services
      ./nix/modules/nixos/wsl
    ];
  };

  inputs = {
    # Core
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    import-tree.url = "github:denful/import-tree";

    # Hosts (nix/hosts)
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

    # Git-sourced k3s bootstrap manifests; update through the flake lock.
    homelab = {
      url = "github:trent-maetzold/homelab";
      flake = false;
    };

    # Imported host services and storage.
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    autolith.url = "github:lambda-symbolics/autolith";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-webui.url = "github:nesquena/hermes-webui";
    hermex-push = {
      url = "github:uzairansaruzi/hermex-push";
      flake = false;
    };
    honcho = {
      url = "github:plastic-labs/honcho";
      flake = false;
    };
    oh-my-hermes = {
      url = "github:rlaope/oh-my-hermes";
      flake = false;
    };
    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Modules (nix/modules/{home,nixos})
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    # Umbriel compositor; cachix tracks the latest commit CI cached, and no
    # nixpkgs follow so those store paths match (its installation guide).
    umbriel.url = "github:noctalia-dev/umbriel/cachix";

    # Packages
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Own nixpkgs (no follows) so packages hit the numtide binary cache.
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    llm-agents.url = "github:numtide/llm-agents.nix";
    # Noctalia community plugins, available for runtime plugin configuration.
    noctalia-plugins = {
      url = "github:noctalia-dev/community-plugins";
      flake = false;
    };
    bkt = {
      url = "github:avivsinai/bitbucket-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Python apps from uv.lock (nix/pkgs/keeper-cli)
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };
  };
}
