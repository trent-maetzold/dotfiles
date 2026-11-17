# CUPS, with network printers found over mDNS.
{config, ...}: let
  modules.nixos = {
    services.printing.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.printing = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.desktop.imports = [config.flake.modules.nixos.printing];
}
