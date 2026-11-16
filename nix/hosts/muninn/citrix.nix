# Citrix Workspace as a normal Niri app. Its windows open fullscreen on the
# "citrix" workspace, and Mod+\ jumps there and back.
{pkgs, ...}: let
  zoom = import ../../pkgs/zoom-vdi {inherit pkgs;};
  usb = pkgs.callPackage ../../pkgs/citrix-usb {};
  client = import ../../pkgs/citrix {inherit pkgs zoom usb;};
  icaroot = "${client}/opt/citrix-icaclient";
in {
  nixpkgs.config.allowUnfreePackages = [
    "citrix-workspace"
    "citrix-usb"
    "zoom-vdi-universal-plugin"
    "linuxx64"
    "ctxusb_26.08.0.225_amd64.deb"
    "zoomvdi-universal-plugin-ubuntu_7.0.13.deb"
  ];
  environment.systemPackages = [client];

  home-manager.users.trent.wayland.windowManager.niri.settings = {
    _children = [
      {workspace._args = ["citrix"];}
      {
        window-rule._children = [
          {match._props.app-id = "^Wfica$";}
          {open-on-workspace = "citrix";}
          {open-fullscreen = true;}
        ];
      }
    ];
    # Pressing a workspace's key again goes back to the previous one.
    input.workspace-auto-back-and-forth = {};
    binds."Mod+Backslash" = {
      _props.hotkey-overlay-title = "Citrix";
      focus-workspace = "citrix";
    };
  };

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
