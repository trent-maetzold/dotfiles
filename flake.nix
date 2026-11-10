{
  description = "Home Manager dotfiles";

  outputs = {
    self,
    nixpkgs,
    import-tree,
    bkt,
    pyproject-nix,
    uv2nix,
    pyproject-build-systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    systems = ["x86_64-linux" "aarch64-linux"];
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    # Local packages as pkgs.<name>; the host flake applies this overlay.
    overlays.default = import ./nix/pkgs {inherit bkt uv2nix pyproject-nix pyproject-build-systems;};

    # The overlay's packages, buildable on their own (`nix build .#tredis`).
    packages = lib.genAttrs systems (system:
      lib.filterAttrs (_: lib.isDerivation)
      (builtins.intersectAttrs (self.overlays.default null null)
        (nixpkgs.legacyPackages.${system}.extend self.overlays.default)));

    # Every module under nix/modules. Modules take this flake's inputs as
    # arguments, so the host passes them: extraSpecialArgs = dotfiles.inputs.
    homeModules.default = import-tree ./nix/modules;

    # devShell that fetches secrets in its shellHook; see nix/dev-shells/mk-secrets-shell.nix.
    lib.mkSecretsShell = import ./nix/dev-shells/mk-secrets-shell.nix;
  };

  inputs = {
    # Core
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    import-tree.url = "github:denful/import-tree";

    # Home Manager modules
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    # Packages
    # Own nixpkgs (no follows) so packages hit the numtide binary cache.
    llm-agents.url = "github:numtide/llm-agents.nix";
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
