{
  perSystem = {final, ...}: let
    deepwiki-cli = final.callPackage ./_package.nix {};
  in {
    packages = {inherit deepwiki-cli;};
    overlayAttrs = {inherit deepwiki-cli;};
  };
}
