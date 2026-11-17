# justine: family desktop with Flatpak, Chrome and LibreOffice; sets her own password at first login.
{config, ...}: let
  inherit (config.flake) homeModules;
in {
  flake.users.justine = config.flake.lib.makeUser {
    name = "justine";
    initialPassword = "changeme";
    imports = [homeModules.justine];
  };

  flake.homeModules.justine = {};
}
