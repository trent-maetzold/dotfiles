# Citrix as its own "OS" on tty8: Xorg (no compositor), a kiosk window manager
# and Workspace at 1920x1200. Ctrl+Alt+F8 and Ctrl+Alt+F1 switch between it
# and Niri; every other key, Win and Alt included, goes to Citrix. Niri knows
# nothing about it.
#
# It runs as trent, so it shares trent's audio: a Bluetooth headset stays
# connected across the switch. logind starts autovt@tty8 the first time tty8
# is switched to; it starts again after Workspace's X exits.
{
  config,
  lib,
  pkgs,
  ...
}: let
  vt = 8;
  niriVt = 1;
  # The employer's DUO_OAUTH store (reached through the cloud.citrix gateway);
  # adding it directly skips the gateway's store picker.
  store = {
    url = "https://storefront.options-it.com/citrix/duo_oauth/discovery";
    host = "storefront.options-it.com/citrix/duo_oauth";
  };

  # nixpkgs' client plus the Zoom VDI plugin (Zoom's audio and video run
  # here instead of through the remote desktop).
  zoom = import ../../../pkgs/zoom-vdi {inherit pkgs;};
  client = pkgs.citrix-workspace.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.python3];
    postInstall =
      (old.postInstall or "")
      + ''
        root="$out/opt/citrix-icaclient"
        ln -s ${zoom}/lib/libZoomPlugin.so "$root/ZoomMedia.so"
        chmod u+w "$root/config/module.ini"
        python3 ${../../../pkgs/citrix/configure.py} "$root/config/module.ini"
        for program in "$out/bin/"*; do
          wrapProgramShell "$program" --set ZOOMMEDIA_INI_PATH ${zoom}/etc/zoomvdi/ZoomMedia.ini
        done
      '';
  });

  wfclient = pkgs.writeText "wfclient.ini" (lib.generators.toINI {} {
    WFClient = {
      Version = 2;
      # Win, Alt+Tab and the like go to Windows.
      TransparentKeyPassthrough = "Remote";
      # Windows at 100% on the 1920x1200 screen.
      DPIMatchingEnabled = "False";
      # No Desktop Viewer bar: the session is switched by tty, not windows.
      ConnectionBar = 0;
    };
    # Decode on the Intel GPU (VA-API) and draw with OpenGL. AV1 is the only
    # video codec offered (the server picks from what the client offers, and
    # offers AV1 only with hardware decoding).
    "Thinwire3.0" = {
      HWAccelerationEnabled = "True";
      OpenGLEnabled = "True";
      H264Enabled = "False";
      H265Enabled = "False";
    };
  });

  session = pkgs.writeShellApplication {
    name = "citrix-session";
    runtimeInputs = [client pkgs.gnugrep pkgs.matchbox pkgs.xrandr pkgs.xset];
    text = lib.replaceStrings ["@storeUrl@" "@storeHost@" "@adwaita@"] [store.url store.host "${pkgs.adwaita-icon-theme}"] (builtins.readFile ./session.sh);
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
    serviceConfig = {
      User = "trent";
      PAMName = "login";
      TTYPath = "/dev/tty${toString vt}";
      StandardInput = "tty";
      StandardOutput = "journal";
      StandardError = "journal";
      UtmpIdentifier = "tty${toString vt}";
      UtmpMode = "user";
      WorkingDirectory = "/home/trent";
    };
    script = ''
      exec ${pkgs.xinit}/bin/xinit ${session}/bin/citrix-session -- \
        ${pkgs.xorg-server}/bin/Xorg :${toString vt} vt${toString vt} -keeptty \
        ${lib.concatStringsSep " " config.services.xserver.displayManager.xserverArgs}
    '';
  };

  home-manager.users.trent = {lib, ...}: {
    # Written over on every switch, then Workspace adds its runtime settings.
    home.activation.citrixConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run install -D -m 0644 ${wfclient} "$HOME/.ICAClient/wfclient.ini"
    '';
  };
}
