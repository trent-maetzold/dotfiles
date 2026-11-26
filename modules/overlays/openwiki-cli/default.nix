{
  perSystem = {final, ...}: let
    openwiki-cli = final.callPackage ./_package.nix {};
  in {
    packages = {inherit openwiki-cli;};
    overlayAttrs = {inherit openwiki-cli;};
  };
}
