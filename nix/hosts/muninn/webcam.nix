# Intel IPU6 webcam via libcamera's software ISP, based on the Omarchy
# troubleshooting notes in infra (docs/notes/omarchy-citrix-webcam.md).
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Do not enable hardware.ipu6: its icamerasrc HAL is not the libcamera
  # pipeline that worked on this camera under Omarchy.
  # Citrix's Nix package already supplies gst-plugins-ugly (x264enc).
  environment.systemPackages = [pkgs.libcamera];

  services.v4l2-relayd.instances.ipu6 = {
    enable = true;
    cardLabel = "Intel MIPI Camera";
    extraPackages = [pkgs.libcamera];
    input = {
      pipeline = "libcamerasrc ! video/x-raw,width=1920,height=1080,framerate=30/1 ! videoconvert";
      format = "NV12";
      width = 1920;
      height = 1080;
      framerate = 30;
    };
    output.format = "NV12";
  };

  # Keep a stable path for Citrix and other applications.
  systemd.services.v4l2-relayd-ipu6 = {
    # Avoid an endless restart loop if the sensor has not probed successfully.
    unitConfig.ConditionPathExists = "/sys/bus/i2c/devices/i2c-OVTI08F4:00/driver";
    serviceConfig.RestartSec = lib.mkForce "10s";
    environment.__EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
    preStart = lib.mkForce ''
      mkdir -p "$(dirname "$V4L2_DEVICE_FILE")"
      if [ -e /sys/class/video4linux/video50/name ]; then
        if [ "$(cat /sys/class/video4linux/video50/name)" != "Intel MIPI Camera" ]; then
          echo "/dev/video50 is in use by another device" >&2
          exit 1
        fi
      else
        ${config.boot.kernelPackages.v4l2loopback.bin}/bin/v4l2loopback-ctl \
          add --name "Intel MIPI Camera" --exclusive-caps=1 --buffers 8 50
      fi
      echo /dev/video50 > "$V4L2_DEVICE_FILE"
    '';
    postStop = lib.mkForce ''
      rm -rf "$(dirname "$V4L2_DEVICE_FILE")"
    '';
  };
}
