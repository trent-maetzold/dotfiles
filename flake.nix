{
  description = "Home Manager dotfiles";

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    import-tree,
    bkt,
    fnox,
    pyproject-nix,
    uv2nix,
    pyproject-build-systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    systems = ["x86_64-linux" "aarch64-linux"];

    trent = {
      name = "trent";
      home = "/home/trent";
      fullName = "Trent Maetzold";
      email = "trent@maetzold.net";
    };
  in {
    # Machines installed straight from this flake (`nix run .#bootstrap -- <host>`).
    nixosConfigurations.muninn = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
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

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    checks = lib.genAttrs systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      vault =
        pkgs.runCommand "vault-gate-check" {
          nativeBuildInputs = [pkgs.bash pkgs.rage pkgs.rbw pkgs.sops inputs.sops-nix.packages.${system}.sops-install-secrets];
        } ''
          mkdir -p nix/lib tests
          cp ${./nix/lib/check-vault.sh} nix/lib/check-vault.sh
          cp ${./tests/check-vault.sh} tests/check-vault.sh
          bash tests/check-vault.sh
          touch "$out"
        '';
    });

    # Local packages as pkgs.<name>; the host flake applies this overlay.
    overlays.default = import ./nix/pkgs {inherit bkt fnox uv2nix pyproject-nix pyproject-build-systems;};

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

    # Every module under nix/modules/{home,nixos}. Modules take this flake's
    # inputs and `user` as arguments, so the host passes them:
    # specialArgs / home-manager.extraSpecialArgs = dotfiles.inputs // {inherit user;}.
    homeModules.default = import-tree ./nix/modules/home;
    nixosModules.default = import-tree ./nix/modules/nixos;
  };

  inputs = {
    # Core
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    import-tree.url = "github:denful/import-tree";

    # Hosts (nix/hosts)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    infra = {
      url = "github:trent-maetzold/infra/staging";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    # Packages
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Own nixpkgs (no follows) so packages hit the numtide binary cache.
    llm-agents.url = "github:numtide/llm-agents.nix";
    bkt = {
      url = "github:avivsinai/bitbucket-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fnox = {
      url = "github:jdx/fnox";
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
