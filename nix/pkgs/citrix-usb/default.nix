{
  lib,
  stdenv,
  requireFile,
  dpkg,
  autoPatchelfHook,
  libcap,
}:
stdenv.mkDerivation {
  pname = "citrix-usb";
  version = "26.08.0.225";
  src = requireFile {
    name = "ctxusb_26.08.0.225_amd64.deb";
    sha256 = "05ggs2gis33y5isnpxkws2rlhzf5f7flyp6c3n3cdgac38gwrgr7";
    message = "Download ctxusb_26.08.0.225_amd64.deb from Citrix, then run nix-prefetch-url file://\u0024PWD/ctxusb_26.08.0.225_amd64.deb";
  };
  nativeBuildInputs = [dpkg autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib libcap];
  runtimeDependencies = [libcap];
  unpackPhase = ''dpkg-deb -x "$src" unpacked'';
  installPhase = ''
    mkdir -p "$out/lib/citrix-usb"
    cp unpacked/opt/Citrix/ICAClient/{ctxusb,ctxusbd,ctx_usb_isactive,VDGUSB.DLL,usb.conf} "$out/lib/citrix-usb/"
    chmod u+w "$out/lib/citrix-usb/"*
  '';
  meta = {
    description = "Citrix USB redirection components";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
  };
}
