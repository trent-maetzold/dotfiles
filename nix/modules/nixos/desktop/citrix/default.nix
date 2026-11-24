# Citrix as its own "OS" on tty8: a single systemd unit runs Xorg, a kiosk
# window manager and Workspace under the user's account. `citrix` in the
# desktop's launcher, or Ctrl+Alt+F8, starts that unit and switches to it; the
# desktop on tty1 is a separate VT and knows nothing about it.
#
# It runs as `user`, so it shares their audio.
{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  vt = 8;
  tty = "tty${toString vt}";
  service = "citrix-kiosk.service";
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

  # The whole session in one place: the store has to exist before the client
  # starts, the kiosk window manager keeps Workspace full-screen, and startx
  # takes Xorg down with the client.
  session = pkgs.writeShellScript "citrix-session" ''
    set -eu
    # Nothing is scrubbed here on purpose: the kiosk gets its own PAM service,
    # so none of the desktop session's variables reach this script. If the client
    # ever ends up back on the compositor, the PAM service is what to check.
    ${pkgs.xset}/bin/xset s off -dpms
    stores=$(${client}/bin/storebrowse --liststores)
    if ! ${pkgs.gnugrep}/bin/grep -qF ${lib.escapeShellArg storeUrl} <<< "$stores"; then
      ${client}/bin/storebrowse --addstore ${lib.escapeShellArg storeUrl}
    fi
    ${pkgs.matchbox}/bin/matchbox-window-manager -use_titlebar no &
    exec ${client}/bin/selfservice
  '';

  runtimeDir = "/run/user/${toString config.users.users.${user.name}.uid}";
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

  # logind only hands out usable (unpaused) DRM fds inside a PAM session, but
  # reusing the `login` service pulls in pam_env, and with it every session
  # variable of the desktop (WAYLAND_DISPLAY, XCURSOR_THEME and the rest) - they
  # override this unit's own environment. Give the kiosk a PAM service that just
  # registers the session and loads nothing from the user's session.
  security.pam.services.citrix-kiosk.text = ''
    auth required ${pkgs.pam}/lib/security/pam_permit.so
    account required ${pkgs.pam}/lib/security/pam_permit.so
    session required ${pkgs.pam}/lib/security/pam_systemd.so
  '';

  systemd.services.citrix-kiosk = {
    description = "Citrix Workspace on ${tty}";
    after = ["systemd-user-sessions.service" "systemd-logind.service"];
    conflicts = ["getty@${tty}.service"];
    restartIfChanged = false;
    environment = {
      XDG_RUNTIME_DIR = runtimeDir;
      DBUS_SESSION_BUS_ADDRESS = "unix:path=${runtimeDir}/bus";
      XDG_DATA_DIRS = "${pkgs.adwaita-icon-theme}/share:/run/current-system/sw/share";
      XCURSOR_PATH = "${pkgs.vanilla-dmz}/share/icons:${pkgs.adwaita-icon-theme}/share/icons";
      XCURSOR_THEME = "DMZ-White";
      XCURSOR_SIZE = "24";
      ZOOMMEDIA_INI_PATH = "${zoom}/etc/zoomvdi/ZoomMedia.ini";
    };
    serviceConfig = {
      User = user.name;
      PAMName = "citrix-kiosk";
      TTYPath = "/dev/${tty}";
      StandardInput = "tty";
      StandardOutput = "journal";
      StandardError = "journal";
      UtmpIdentifier = tty;
      UtmpMode = "user";
      WorkingDirectory = user.home;
      # DISPLAY must stay unset: startx sets it and refuses to run otherwise.
      ExecStart = lib.concatStringsSep " " ([
          "${pkgs.xinit}/bin/startx"
          "${session}"
          "--"
          ":${toString vt}"
          "vt${toString vt}"
          "-keeptty"
          "-noreset"
        ]
        ++ lib.remove "-terminate" config.services.xserver.displayManager.xserverArgs);
      # Xorg opens DRM through logind, and logind hands out a *paused* fd unless
      # the VT is active ("Error systemd-logind returned paused fd for drm
      # node"). So the session has to bring its own VT up before startx runs.
      ExecStartPre = "+${pkgs.kbd}/bin/chvt ${toString vt}";
      # The kiosk is meant to be up whenever the VT is, so restart the session
      # rather than leaving a dead VT behind.
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # Keep Ctrl+Alt+F8 useful: logind starts this on a switch to the VT, and it
  # only starts the kiosk. It must *finish* so that the next switch to the VT
  # triggers it again (a RemainAfterExit unit stays active and never re-fires,
  # which left tty8 blank once the kiosk had been stopped). Stopping it does not
  # stop the kiosk.
  services.logind.settings.Login.NAutoVTs = vt;
  systemd.services."autovt@${tty}" = {
    description = "Start the Citrix kiosk on ${tty}";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl start --no-block ${service}";
    };
  };

  # Launching the client — from the desktop's launcher or a terminal — brings
  # the kiosk up if it is not running and switches to it. The switch goes
  # through logind, which is allowed to activate the session it already owns.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "citrix" ''
      set -eu
      ${pkgs.systemd}/bin/systemctl start ${service}
      for _ in $(${pkgs.coreutils}/bin/seq 50); do
        session=$(${pkgs.systemd}/bin/loginctl list-sessions --no-legend |
          ${pkgs.gawk}/bin/awk -v t=${tty} '$5 == t {print $1; exit}')
        if [ -n "$session" ]; then
          exec ${pkgs.systemd}/bin/loginctl activate "$session"
        fi
        ${pkgs.coreutils}/bin/sleep 0.2
      done
      echo "citrix: no session appeared on ${tty}" >&2
      exit 1
    '')
    (pkgs.makeDesktopItem {
      name = "citrix";
      desktopName = "Citrix Workspace";
      comment = "Open Citrix Workspace on ${tty}";
      exec = "citrix";
      icon = "applications-internet";
      categories = ["Network"];
      terminal = false;
    })
  ];

  # The launcher above starts the kiosk; ask polkit to allow that one unit
  # without a password prompt.
  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "${user.name}" &&
          action.lookup("unit") == "${service}")
        return polkit.Result.YES;
    });
  '';

  home-manager.users.${user.name}.home.file.".ICAClient/All_Regions.ini" = {
    source = allRegions;
    force = true;
  };
}
