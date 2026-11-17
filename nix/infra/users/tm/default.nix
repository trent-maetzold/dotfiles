# tm: the workstation user; tm-server is the same user with server tooling only.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) homeModules;

  tm = imports:
    config.flake.lib.makeUser {
      name = "tm";
      groups = ["wheel"];
      shell = "zsh";
      publicKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds trent@muninn" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6sEj9jzEpu4Cbko4lLq54i16hM4RyIFmaIM5uZ2RH8 trent@huginn"];
      inherit (config.flake) hosts;
      specialArgs = inputs;

      git = {
        name = "Trent Maetzold";
        email = "trent@maetzold.co";
      };

      inherit imports;
    };
in {
  flake.users = {
    tm = tm [homeModules.tm];
    # Servers: shell, git and nix tooling only.
    tm-server = tm [homeModules.default-slim];
  };

  flake.homeModules.tm.imports = [
    homeModules.default
    homeModules.infra
  ];

  perSystem = {system, ...}: {
    legacyPackages.homeConfigurations.tm = config.flake.users.tm.homeConfiguration system;
  };
}
