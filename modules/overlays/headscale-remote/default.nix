{
  perSystem = {final, ...}: let
    headscale-remote = final.callPackage ./_package.nix {};
  in {
    packages = {inherit headscale-remote;};
    overlayAttrs = {inherit headscale-remote;};
  };
}
