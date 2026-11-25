{ config, ... }:
let
  inherit (config.flake) nixos homeManager;

  trent = {
    username = "trent";
    name = "Trent Maetzold";
    email = "trent@maetzold.net";
  };
  trent-work = {
    username = "tmaetzold_gcp";
    name = "Trent Maetzold";
    email = "trent.maetzold@gardacp.com";
  };

  homeUser = { user }: {
    home = {
      username = user.name;
      homeDirectory = user.home;
      stateVersion = "26.11";
    };
    xdg = {
      enable = true;
      preferXdgDirectories = true;
    };
  };
  nixosUser = { user }: {
    users.users.${user.username} = {
      isNormalUser = true;
      description = user.name;
      extraGroups = [ "wheel" ];
    };
  };
in
{
  flake.modules.homeManager.trent.imports = with homeManager; [
    (homeUser trent)
    default
  ];

  flake.modules.homeManager.trent-slim.imports = with homeManager; [
    (homeUser trent)
    default
  ];

  flake.modules.homeManager.trent-work.imports = with homeManager; [
    (homeUser trent-work)
    default
  ];

  flake.modules.nixos.trent.imports = with nixos; [
    (nixosUser trent)
    default
  ];

  flake.modules.nixos.trent-work.imports = with nixos; [
    (nixosUser trent-work)
    default
  ];
}
