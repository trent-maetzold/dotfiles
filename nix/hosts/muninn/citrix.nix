# Citrix Workspace as a normal Niri app. Its session windows open
# fullscreen on the "citrix" workspace; Mod+\ jumps there and back.
# The downloads are manual: see `nix build nixpkgs#citrix-workspace` and
# nix/pkgs/zoom-vdi. The Zoom plugin sends Zoom's audio and video from this
# laptop instead of through the remote desktop.
{pkgs, ...}: let
  zoom = import ../../pkgs/zoom-vdi {inherit pkgs;};
  client = pkgs.citrix-workspace.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.python3];
    postInstall =
      (old.postInstall or "")
      + ''
        root="$out/opt/citrix-icaclient"
        ln -s ${zoom}/lib/libZoomPlugin.so "$root/ZoomMedia.so"
        chmod u+w "$root/config/module.ini"
        python3 ${../../pkgs/citrix/configure.py} "$root/config/module.ini"
        for program in "$out/bin/"*; do
          wrapProgramShell "$program" --set ZOOMMEDIA_INI_PATH ${zoom}/etc/zoomvdi/ZoomMedia.ini
        done
      '';
  });
in {
  # The client, the Zoom plugin and their downloads.
  nixpkgs.config.allowUnfreePackages = ["citrix-workspace" "linuxx64" "zoom-vdi-universal-plugin" "zoomvdi-universal-plugin-ubuntu_7.0.13.deb"];
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
}
