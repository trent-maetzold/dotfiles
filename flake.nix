{
  description = "Home Manager dotfiles";

  inputs.import-tree.url = "github:denful/import-tree";
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  # Own nixpkgs (no follows) so packages hit the numtide binary cache.
  inputs.llm-agents.url = "github:numtide/llm-agents.nix";
  inputs.bkt.url = "github:avivsinai/bitbucket-cli";
  inputs.bkt.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, import-tree, llm-agents, bkt, ... }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
      export-windows-cas = nixpkgs.legacyPackages.${system}.callPackage ./nix/pkgs/export-windows-cas.nix { };
      openwiki = nixpkgs.legacyPackages.${system}.callPackage ./nix/pkgs/openwiki { };
    });

    homeModules.default = { pkgs, ... }: {
      imports = [
        (import-tree ./nix/modules)
      ];
      _module.args.llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      _module.args.bkt = bkt.packages.${pkgs.stdenv.hostPlatform.system}.bkt;
    };
  };
}
