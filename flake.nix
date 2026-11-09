{
  description = "Home Manager dotfiles";

  inputs.import-tree.url = "github:denful/import-tree";
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

  outputs = { nixpkgs, import-tree, ... }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
      export-windows-cas = nixpkgs.legacyPackages.${system}.callPackage ./nix/pkgs/export-windows-cas.nix { };
      billion-context = nixpkgs.legacyPackages.${system}.callPackage ./nix/pkgs/billion-context { };
    });

    homeModules.default = {
      imports = [
        (import-tree ./nix/modules)
      ];
    };
  };
}
