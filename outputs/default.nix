inputs:
inputs.flake-parts.lib.mkFlake {inherit inputs;} {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-parts.flakeModules.easyOverlay

    (inputs.import-tree ../modules)
  ];

  systems = ["x86_64-linux" "aarch64-linux"];
  flake.formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
}
