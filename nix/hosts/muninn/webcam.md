# Muninn webcam

The IPU6 relay uses libcamera's software ISP rather than Intel's `icamerasrc`
HAL, as in the [Omarchy Citrix webcam notes](https://github.com/trent-maetzold/infra/blob/staging/docs/notes/omarchy-citrix-webcam.md).
It exposes a stable `/dev/video50` at 1920x1080 NV12 and selects Mesa EGL
instead of NVIDIA. The Citrix package already includes the x264 GStreamer
plugin.

On the initial boot the OV08X40 sensor failed to bind with I2C error `-121`,
and `cam -l` reported no sensor. After the operator retried the sensor bind,
libcamera detected the camera and captured frames; a GStreamer test also
negotiated 1920x1080 NV12 using Mesa on the Intel GPU. The cause of the initial
probe failure is not established. A closed physical shutter can cause white
frames; opening it is not proof of the cause of an I2C error.

After activating the module and fixing sensor detection, check `cam -l`,
`systemctl status v4l2-relayd-ipu6`, then test the loopback with a camera
application. If the sensor binds after the service was skipped, start the
service manually. Verify live frames before testing Citrix.

For Citrix, the Arch notes specify these settings under `[WFClient]` in the
mutable `~/.ICAClient/wfclient.ini`: `HDXWebCamEnabled=True`,
`HDXWebCamEnablePnp=False`, `HDXWebCamDevice=/dev/video50`,
`HDXWebCamWidth=1920`, `HDXWebCamHeight=1080` and
`HDXH264InputEnabled=True`. They are not managed by this module; don't
replace the existing Citrix configuration. Check the current keys and test a
remote session after the local camera works.

The running kernel has no `/dev/dma_heap/system`, but exposes
`/dev/udmabuf`; upstream libcamera's software ISP can use it as a fallback.
A direct capture succeeded, but the loopback relay and Citrix redirection remain
untested. No captured image was saved or visually inspected.
