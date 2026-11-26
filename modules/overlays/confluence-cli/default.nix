{
  perSystem = {final, ...}: let
    confluence-cli = final.callPackage ./_package.nix {};
  in {
    packages = {inherit confluence-cli;};
    overlayAttrs = {inherit confluence-cli;};
  };
}
