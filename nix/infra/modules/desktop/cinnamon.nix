# Cinnamon on X11 with LightDM; it brings NetworkManager, PipeWire and portals.
{config, ...}: let
  modules.nixos = {
    services.xserver = {
      enable = true;
      desktopManager.cinnamon.enable = true;
    };

    security.rtkit.enable = true;
    # AccountsService keeps each user's session, language and picture.
    persistence.dirs."/var/lib/AccountsService" = {};
    # Users with an empty password log in without one.
    security.pam.services.lightdm.allowNullPassword = true;
  };
in {
  # Flake Modules
  flake.modules.nixos.cinnamon = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.desktop.imports = [config.flake.modules.nixos.cinnamon];
}
