{
  pkgs,
  zoom,
  usb,
}:
pkgs.citrix-workspace.overrideAttrs (old: {
  version = "26.08.0.225";
  src = pkgs.requireFile {
    name = "linuxx64-26.08.0.225.tar.gz";
    sha256 = "185sbj67b12iz2s49g0q1ixby79r8c2xflsvl2fghmh6ap1d8ca2";
    message = "Download linuxx64-26.08.0.225.tar.gz from Citrix, then run nix-prefetch-url on its local file:// URL.";
  };
  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.python3];
  runtimeDependencies = (old.runtimeDependencies or []) ++ [pkgs.libcap];
  postInstall =
    (old.postInstall or "")
    + ''
      root="$out/opt/citrix-icaclient"
      cp ${usb}/lib/citrix-usb/{VDGUSB.DLL,ctxusbd,ctx_usb_isactive,usb.conf} "$root/"
      # The privileged helper validates that its real ELF is beside wfica.
      cp ${usb}/lib/citrix-usb/ctxusb "$root/ctxusb.real"
      ln -s /run/wrappers/bin/ctxusb "$root/ctxusb"
      ln -s ${zoom}/lib/libZoomPlugin.so "$root/ZoomMedia.so"
      chmod u+w "$root/config/module.ini"
      python3 ${./configure.py} "$root/config/module.ini"
      # Preserve the real wfica ELF/name for ctxusb's parent-process checks.
      for program in "$out/bin/"*; do
        wrapProgramShell "$program" \
          --set ZOOMMEDIA_INI_PATH ${zoom}/etc/zoomvdi/ZoomMedia.ini
      done
    '';
})
