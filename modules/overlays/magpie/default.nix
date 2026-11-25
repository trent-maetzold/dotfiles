{
  perSystem = {final, ...}: {
    overlayAttrs = {
      magpie-cli = final.callPackage ./_package-cli.nix {};
      magpie-desktop = final.callPackage ./_package-desktop.nix {};
    };
  };
}
