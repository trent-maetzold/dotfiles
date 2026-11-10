{
  description = "Home Manager dotfiles";

  inputs.bkt.url = "github:avivsinai/bitbucket-cli";
  inputs.bkt.inputs.nixpkgs.follows = "nixpkgs";
  inputs.import-tree.url = "github:denful/import-tree";
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  # Own nixpkgs (no follows) so packages hit the numtide binary cache.
  inputs.llm-agents.url = "github:numtide/llm-agents.nix";
  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  # Python apps from uv.lock (nix/pkgs/keeper-cli).
  inputs.pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
  inputs.pyproject-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.uv2nix.url = "github:pyproject-nix/uv2nix";
  inputs.uv2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.uv2nix.inputs.pyproject-nix.follows = "pyproject-nix";
  inputs.pyproject-build-systems.url = "github:pyproject-nix/build-system-pkgs";
  inputs.pyproject-build-systems.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pyproject-build-systems.inputs.pyproject-nix.follows = "pyproject-nix";
  inputs.pyproject-build-systems.inputs.uv2nix.follows = "uv2nix";

  outputs = {
    self,
    nixpkgs,
    bkt,
    import-tree,
    llm-agents,
    nix-index-database,
    sops-nix,
    uv2nix,
    pyproject-nix,
    pyproject-build-systems,
    ...
  }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    overlays.default = import ./nix/pkgs {inherit bkt uv2nix pyproject-nix pyproject-build-systems;};

    packages = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"] (system:
      nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation)
      (builtins.intersectAttrs (self.overlays.default null null)
        (nixpkgs.legacyPackages.${system}.extend self.overlays.default)));

    homeModules.default = {pkgs, ...}: {
      imports = [
        (import-tree ./nix/modules)
        sops-nix.homeManagerModules.sops
        nix-index-database.homeModules.nix-index
      ];
      _module.args.llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    };
  };
}
