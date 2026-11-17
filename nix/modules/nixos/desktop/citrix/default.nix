# Citrix as its own "OS" on tty8: Xorg (no compositor), a kiosk window manager
# and Workspace. Ctrl+Alt+F8 and Ctrl+Alt+F1 switch between it and the desktop
# on tty1; every other key, Win and Alt included, goes to Citrix. The desktop
# knows nothing about it.
#
# It runs as `user`, so it shares their audio: a Bluetooth headset stays
# connected across the switch. logind starts autovt@tty8 the first time tty8
# is switched to; it starts again after Workspace's X exits.
{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  vt = 8;
  # Use the public gateway; its internal StoreFront hostname is not reachable here.
  storeUrl = "https://cloud.citrix.options-it.com";

  # nixpkgs' client plus the Zoom VDI plugin (Zoom's audio and video run
  # here instead of through the remote desktop).
  zoom = import ../../../../pkgs/zoom-vdi {inherit pkgs;};

  allRegions = (pkgs.formats.ini {}).generate "All_Regions.ini" {
    "Top Level" = {
      EnableLockdown = true;
      AllowConnection = true;
      OverrideInvalidICAParameters = true;
      AllowUnrecognisedICAParameters = true;
    };
    "Client Engine\\GUI".ConnectionBar = "0";
    "Virtual Channels\\Keyboard".TransparentKeyPassthrough = "Remote";
    "Virtual Channels\\Thinwire Graphics" = {
      DPIMatchingEnabled = "False";
      HWAccelerationEnabled = "True";
      OpenGLEnabled = "True";
      H264Enabled = "True";
      H265Enabled = "True";
    };
  };
  client = pkgs.citrix-workspace.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.python3];
    postInstall =
      (old.postInstall or "")
      + ''
        root="$out/opt/citrix-icaclient"
        ln -s ${zoom}/lib/libZoomPlugin.so "$root/ZoomMedia.so"
        chmod u+w "$root/config/module.ini"
        python3 ${../../../../pkgs/citrix/configure.py} "$root/config/module.ini"
      '';
  });

  session = pkgs.writeShellApplication {
    name = "citrix-session";
    runtimeInputs = [client pkgs.gnugrep pkgs.matchbox pkgs.xset];
    text = lib.replaceStrings ["@storeUrl@" "@adwaita@"] [storeUrl "${pkgs.adwaita-icon-theme}"] (builtins.readFile ./session.sh);
  };
in {
  # The client, the Zoom plugin and their manual downloads.
  nixpkgs.config.allowUnfreePackages = [
    "citrix-workspace"
    "linuxx64"
    "zoom-vdi-universal-plugin"
    "zoomvdi-universal-plugin-ubuntu_7.0.13.deb"
  ];

  # Xorg's config and modules, without a display manager (greetd stays).
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    # The display number is set below (:8), not in the shared X arguments.
    display = null;
  };

  # logind starts autovt@ttyN on first switch only for N <= NAutoVTs.
  services.logind.settings.Login.NAutoVTs = vt;
  systemd.services."autovt@tty${toString vt}" = {
    description = "Citrix Workspace on tty${toString vt}";
    after = ["systemd-user-sessions.service" "systemd-logind.service"];
    conflicts = ["getty@tty${toString vt}.service"];
    restartIfChanged = false;
    environment.ZOOMMEDIA_INI_PATH = "${zoom}/etc/zoomvdi/ZoomMedia.ini";
    serviceConfig = {
      User = user.name;
      PAMName = "login";
      TTYPath = "/dev/tty${toString vt}";
      StandardInput = "tty";
      StandardOutput = "journal";
      StandardError = "journal";
      UtmpIdentifier = "tty${toString vt}";
      UtmpMode = "user";
      WorkingDirectory = user.home;
    };
    script = ''
      exec ${pkgs.xinit}/bin/xinit ${session}/bin/citrix-session -- \
        ${pkgs.xorg-server}/bin/Xorg :${toString vt} vt${toString vt} -keeptty \
        ${lib.concatStringsSep " " config.services.xserver.displayManager.xserverArgs}
    '';
  };

  home-manager.users.${user.name}.home.file.".ICAClient/All_Regions.ini" = {
    source = allRegions;
    force = true;
  };
}
