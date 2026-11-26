{
  perSystem = {final, ...}: let
    tredis = final.callPackage ./_package.nix {};
  in {
    packages = {inherit tredis;};
    overlayAttrs = {inherit tredis;};
  };
}
