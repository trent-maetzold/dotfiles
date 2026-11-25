{inputs, ...}: {
  perSystem = {final, ...}: let
    keeper = final.callPackage ./_package.nix {inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;};
  in {
    overlayAttrs.keeper-commander = keeper.keeper-commander;
    overlayAttrs.keeper-secrets-manager-cli = keeper.keeper-secrets-manager-cli;
  };
}
