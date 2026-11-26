{inputs, ...}: {
  perSystem = {system, ...}: let
    inherit (inputs.bkt.packages.${system}) bkt;
  in {
    packages = {inherit bkt;};
    overlayAttrs = {inherit bkt;};
  };
}
