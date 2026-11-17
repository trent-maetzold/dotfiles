# Citrix on muninn: a 1920x1200 screen (half the panel's resolution),
# with NVIDIA hidden so Workspace permits Intel hardware decoding.
{
  imports = [../../modules/nixos/desktop/citrix];

  services.xserver.xrandrHeads = [
    {
      output = "eDP-1";
      primary = true;
      monitorConfig = ''Option "PreferredMode" "1920x1200"'';
    }
  ];

  systemd.services."autovt@tty8" = {
    # shortcut: fixed GPU/audio PCI parent; update if muninn's PCI topology changes.
    serviceConfig.InaccessiblePaths = ["/sys/devices/pci0000:00/0000:00:1c.0"];
    environment.__EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
  };
}
