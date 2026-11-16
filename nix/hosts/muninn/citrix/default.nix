# Citrix as its own "OS" on tty8: Xorg (no compositor), a kiosk window manager
# and Workspace, as the citrix user, at 1920x1200. Win+\ switches between it
# and Niri on tty1, through the keymaps (keymap.nix); every other key, Win and
# Alt included, goes to Citrix. Niri knows nothing about it.
#
# logind starts autovt@tty8 the first time tty8 is switched to, so the session
# starts while its VT is active; it starts again after Workspace's X exits.
{
  config,
  lib,
  pkgs,
  ...
}: let
  vt = 8;
  niriVt = 1;
  store = {
    url = "https://cloud.citrix.options-it.com";
    host = "cloud.citrix.options-it.com";
  };

  zoom = import ../../../pkgs/zoom-vdi {inherit pkgs;};
  usb = pkgs.callPackage ../../../pkgs/citrix-usb {};
  client = import ../../../pkgs/citrix {inherit pkgs zoom usb;};
  icaroot = "${client}/opt/citrix-icaclient";

  keymaps = pkgs.callPackage ./keymap.nix {
    citrixVt = vt;
    inherit niriVt;
  };

  session = pkgs.writeShellApplication {
    name = "citrix-session";
    runtimeInputs = [
      client
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.matchbox
      pkgs.xkbcomp
      pkgs.xmodmap
      pkgs.xorg-server # cvt
      pkgs.xrandr
      pkgs.xset
    ];
    text = lib.replaceStrings ["@keymap@" "@xkbdir@" "@storeUrl@" "@storeHost@" "@adwaita@"] ["${keymaps}/xorg.xkb" config.services.xserver.xkb.dir store.url store.host "${pkgs.adwaita-icon-theme}"] (builtins.readFile ./session.sh);
  };

  gtkSettings = lib.generators.toINI {} {
    Settings = {
      gtk-theme-name = "Adwaita";
      gtk-application-prefer-dark-theme = 1;
      gtk-icon-theme-name = "Adwaita";
      gtk-cursor-theme-name = "Adwaita";
      gtk-cursor-theme-size = 24;
    };
  };

  wfclient = lib.generators.toINI {} {
    WFClient = {
      Version = 2;
      # Win, Alt+Tab and the like go to Windows.
      TransparentKeyPassthrough = "Remote";
      # Windows at 100% on the 1920x1200 screen.
      DPIMatchingEnabled = "False";
    };
  };
in {
  nixpkgs.config.allowUnfreePackages = [
    "citrix-workspace"
    "citrix-usb"
    "zoom-vdi-universal-plugin"
    "linuxx64"
    "ctxusb_26.08.0.225_amd64.deb"
    "zoomvdi-universal-plugin-ubuntu_7.0.13.deb"
  ];

  # Xorg's config and modules, without a display manager (greetd stays).
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    # The display number is set below (:8), not in the shared X arguments.
    display = null;
  };

  users.users.citrix = {
    isSystemUser = true;
    group = "citrix";
    home = "/home/citrix";
    createHome = true;
    shell = pkgs.bashInteractive;
  };
  users.groups.citrix = {};

  systemd.tmpfiles.rules = [
    "d /home/citrix/.ICAClient 0700 citrix citrix -"
    "L+ /home/citrix/.ICAClient/wfclient.ini - - - - ${pkgs.writeText "wfclient.ini" wfclient}"
    "d /home/citrix/.config 0700 citrix citrix -"
    "d /home/citrix/.config/gtk-3.0 0700 citrix citrix -"
    "L+ /home/citrix/.config/gtk-3.0/settings.ini - - - - ${pkgs.writeText "gtk-settings.ini" gtkSettings}"
  ];

  # logind starts autovt@ttyN on first switch only for N <= NAutoVTs.
  services.logind.settings.Login.NAutoVTs = vt;
  systemd.services."autovt@tty${toString vt}" = {
    description = "Citrix Workspace on tty${toString vt}";
    after = ["systemd-user-sessions.service" "systemd-logind.service"];
    conflicts = ["getty@tty${toString vt}.service"];
    restartIfChanged = false;
    serviceConfig = {
      User = "citrix";
      PAMName = "login";
      TTYPath = "/dev/tty${toString vt}";
      StandardInput = "tty";
      StandardOutput = "journal";
      StandardError = "journal";
      UtmpIdentifier = "tty${toString vt}";
      UtmpMode = "user";
      WorkingDirectory = "/home/citrix";
    };
    script = ''
      exec ${pkgs.xinit}/bin/xinit ${session}/bin/citrix-session -- \
        ${pkgs.xorg-server}/bin/Xorg :${toString vt} vt${toString vt} -keeptty \
        ${lib.concatStringsSep " " config.services.xserver.displayManager.xserverArgs}
    '';
  };

  # Niri's side of Win+\.
  home-manager.users.trent.wayland.windowManager.niri.settings.input.keyboard.xkb.file = "${keymaps}/niri.xkb";

  # USB redirection: Citrix's broker and its setuid helper.
  security.wrappers.ctxusb = {
    source = "${icaroot}/ctxusb.real";
    owner = "root";
    group = "root";
    setuid = true;
    permissions = "u+rx,g+rx,o+rx";
  };
  systemd.services.ctxusbd = {
    description = "Citrix USB redirection broker";
    wantedBy = ["multi-user.target"];
    after = ["systemd-udevd.service"];
    unitConfig.ConditionPathIsDirectory = "/dev/bus/usb";
    environment.ICAROOT = icaroot;
    serviceConfig = {
      Type = "forking";
      RuntimeDirectory = "ctxusbd";
      RuntimeDirectoryMode = "0700";
      ExecStart = "${icaroot}/ctxusbd";
      Restart = "on-failure";
    };
  };
}
