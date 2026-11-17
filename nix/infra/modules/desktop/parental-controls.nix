# Malcontent parental controls: members of `kids` can't install Flatpak apps.
{config, ...}: let
  modules.nixos = {pkgs, ...}: {
    services.malcontent.enable = true;
    users.groups.kids = {};

    # Malcontent keeps filters in AccountsService's state, so they are set each boot.
    systemd.services.parental-controls = {
      wantedBy = ["multi-user.target"];
      wants = ["accounts-daemon.service"];
      after = ["accounts-daemon.service"];
      path = [pkgs.getent pkgs.malcontent];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        for kid in $(getent group kids | cut -d: -f4 | tr , ' '); do
          malcontent-client set-app-filter -n --disallow-user-installation --disallow-system-installation "$kid"
        done
      '';
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.parental-controls = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.desktop.imports = [config.flake.modules.nixos.parental-controls];
}
