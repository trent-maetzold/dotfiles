{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay];
  flake.formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
}
