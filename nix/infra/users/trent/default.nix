# trent: tm's workstation setup under the new name; features add the rest.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) homeModules;
in {
  flake.users.trent = config.flake.lib.makeUser {
    name = "trent";
    groups = ["wheel"];
    shell = "zsh";
    publicKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds trent@muninn" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6sEj9jzEpu4Cbko4lLq54i16hM4RyIFmaIM5uZ2RH8 trent@huginn"];
    inherit (config.flake) hosts;
    specialArgs = inputs;

    git = {
      name = "Trent Maetzold";
      email = "trent@maetzold.co";
    };

    imports = [
      homeModules.default
      homeModules.infra
      homeModules.trent
    ];
  };

  flake.homeModules.trent = {};
}
