{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  makeDesktopItem,
  wayland,
  gtk3,
  glib,
  gdk-pixbuf,
  fontconfig,
  libX11,
  webkitgtk_4_1,
  libsoup_3,
}: let
  version = "0.1.4572";
  cli = fetchurl {
    url = "https://usemagpie.ai/files/v${version}/magpie-cli-linux-amd64";
    hash = "sha256-WxW6O15v3D+gvbhRrlJiGqO6kzzvt6u/Y9U9NKZ2eOM=";
  };
  gui = fetchurl {
    url = "https://usemagpie.ai/files/v${version}/magpie-linux-amd64";
    hash = "sha256-uBFHkePVZ4GOnnWNISzwPmKaYtC6PEYZf1gxl/aSZ6o=";
  };
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/yetone/magpie/v${version}/site/public/img/icon-256.png";
    hash = "sha256-V0N8ZZbgWo/PxC1CiMAwqgDthraf411GTWnXAmFQxwQ=";
  };
  desktopItem = makeDesktopItem {
    name = "magpie";
    desktopName = "Magpie";
    exec = "magpie-desktop";
    icon = "magpie";
    categories = ["Utility"];
  };
in
  stdenv.mkDerivation {
    pname = "magpie";
    inherit version;
    outputs = ["out" "desktop"];

    dontUnpack = true;
    dontWrapGApps = true;
    nativeBuildInputs = [autoPatchelfHook wrapGAppsHook3 makeWrapper];
    buildInputs = [wayland gtk3 glib gdk-pixbuf fontconfig libX11 webkitgtk_4_1 libsoup_3];
    installPhase = ''
      runHook preInstall
      install -Dm755 ${cli} "$out/bin/magpie"
      install -Dm755 ${gui} "$desktop/bin/magpie-desktop"
      install -Dm644 ${icon} "$desktop/share/icons/hicolor/256x256/apps/magpie.png"
      install -Dm644 ${desktopItem}/share/applications/magpie.desktop "$desktop/share/applications/magpie.desktop"
      runHook postInstall
    '';
    preFixup = ''
      wrapProgram "$desktop/bin/magpie-desktop" "''${gappsWrapperArgs[@]}"
    '';

    meta = {
      description = "Magpie model gateway and desktop app";
      homepage = "https://github.com/yetone/magpie";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "magpie";
    };
  }
