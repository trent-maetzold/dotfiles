{pkgs}: let
  inherit (pkgs) lib;
  unpacked = pkgs.stdenvNoCC.mkDerivation {
    pname = "zoom-vdi-unpacked";
    version = "7.0.13.27170";
    src = pkgs.requireFile {
      name = "zoomvdi-universal-plugin-ubuntu_7.0.13.deb";
      sha256 = "03b10hi4l8cai4w1nqparkr9n7y0h1rsnasaw6hxiqyv5kk6hjma";
      message = "Download zoomvdi-universal-plugin-ubuntu_7.0.13.deb from Zoom, then run nix-prefetch-url on the local file:// URL.";
    };
    nativeBuildInputs = [pkgs.dpkg];
    dontUnpack = true;
    dontFixup = true;
    installPhase = ''dpkg-deb -x "$src" "$out"'';
  };
  # Like nixpkgs' Zoom package, keep the vendor Qt bundle inside an FHS runtime.
  runtime = pkgs.buildFHSEnv {
    name = "zoom-vdi";
    targetPkgs = p:
      with p; [
        alsa-lib
        atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        glib
        gtk3
        libGL
        libGLU
        libdrm
        libgbm
        libkrb5
        libpulseaudio
        libsm
        libice
        libx11
        libxext
        libxv
        libxfixes
        libxi
        libxrender
        libxrandr
        libxtst
        libxkbcommon
        libxcb
        libxcb-util
        libxcb-cursor
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libxcb-wm
        nss
        nspr
        pango
        stdenv.cc.cc.lib
        udev
        wayland
        zlib
        zstd
      ];
    extraBwrapArgs = ["--ro-bind ${unpacked}/usr/lib/zoomvdi-universal-plugin /usr/lib/zoomvdi-universal-plugin"];
    extraPreBwrapCmds = "unset QT_PLUGIN_PATH";
    profile = ''
      export LD_LIBRARY_PATH="/usr/lib/zoomvdi-universal-plugin/Qt/lib:/usr/lib/zoomvdi-universal-plugin''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    '';
    runScript = "/usr/lib/zoomvdi-universal-plugin/zoom";
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "zoom-vdi-universal-plugin";
    inherit (unpacked) version;
    dontUnpack = true;
    nativeBuildInputs = [pkgs.autoPatchelfHook];
    buildInputs = [pkgs.glib pkgs.libx11 pkgs.libxext pkgs.libxcb pkgs.stdenv.cc.cc.lib];
    installPhase = ''
      mkdir -p "$out/lib" "$out/etc/zoomvdi"
      cp ${unpacked}/usr/lib/zoomvdi-universal-plugin/libZoomPlugin.so "$out/lib/"
      cp ${unpacked}/etc/zoomvdi/ZoomMedia.ini "$out/etc/zoomvdi/"
      chmod u+w "$out/etc/zoomvdi/ZoomMedia.ini"
      substituteInPlace "$out/etc/zoomvdi/ZoomMedia.ini" \
        --replace-fail $'\nPATH=/usr/lib/zoomvdi-universal-plugin/' $'\nPATH=${runtime}/bin/' \
        --replace-fail $'\nBIN=zoom' $'\nBIN=zoom-vdi'
      grep -q '^PATH=${runtime}/bin/' "$out/etc/zoomvdi/ZoomMedia.ini"
      grep -q '^LD_LIBRARY_PATH=/usr/lib/zoomvdi-universal-plugin/Qt/lib/' "$out/etc/zoomvdi/ZoomMedia.ini"
    '';
    meta = {
      description = "Zoom universal VDI plugin with an isolated vendor runtime";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  }
