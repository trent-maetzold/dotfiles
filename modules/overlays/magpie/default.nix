{
  perSystem = {final, ...}: let
    magpie-cli = final.callPackage ./_package-cli.nix {};
    magpie-desktop = final.callPackage ./_package-desktop.nix {};
  in {
    packages = {inherit magpie-cli magpie-desktop;};
    overlayAttrs = {inherit magpie-cli magpie-desktop;};
  };
}
