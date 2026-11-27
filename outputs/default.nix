inputs:
inputs.flake-parts.lib.mkFlake {inherit inputs;} {
  imports = [
    inputs.flake-parts.flakeModules.modules

    (inputs.import-tree ../modules)
  ];

  flake.overlays.default = inputs.zoldt-pkgs.modules.overlays.default;
  systems = ["x86_64-linux" "aarch64-linux"];
  flake.formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
}
