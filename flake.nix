{
  description = "trent's dotfiles: home-manager only, dendritic";

  # Honoured for trusted users (or with --accept-flake-config).
  nixConfig = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };

  # Every file under ./nix is a flake-parts module (dendritic). These are
  # passed to all of them as module arguments.
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        username = "trent";
        stateVersion = "26.05";
        gitName = "Trent Maetzold";
        gitEmail = "trent@maetzold.net";
        workEmail = "CHANGEME@work.example"; # TODO: real work address
      };
    } {
      imports = [
        inputs.flake-parts.flakeModules.modules # flake.modules.<class>.<feature>
        inputs.home-manager.flakeModules.home-manager # flake.homeModules / homeConfigurations
        (inputs.import-tree ./nix)
      ];

      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {pkgs, ...}: {formatter = pkgs.alejandra;};
    };
}
