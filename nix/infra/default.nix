# Local configuration registry from infra/staging (094c13a). Keep its profiles
# separate from this flake's laptop defaults; no deployment machinery is loaded.
{inputs}: let
  moduleInputs = inputs // import ./vars.nix // {secrets = ./secrets.yaml;};
in
  inputs.flake-parts.lib.mkFlake {
    inputs = moduleInputs;
    specialArgs = moduleInputs;
  } {
    imports = [
      inputs.flake-parts.flakeModules.modules
      inputs.home-manager.flakeModules.home-manager
      (inputs.import-tree [./hosts ./lib ./modules ./options ./users])
    ];
    systems = [];
  }
