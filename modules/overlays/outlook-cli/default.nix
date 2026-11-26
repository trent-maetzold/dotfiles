{
  perSystem = {final, ...}: let
    outlook-cli = final.callPackage ./_package.nix {};
  in {
    packages = {inherit outlook-cli;};
    overlayAttrs = {inherit outlook-cli;};
  };
}
