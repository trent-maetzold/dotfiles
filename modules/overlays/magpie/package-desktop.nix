{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeDesktopItem,
  copyDesktopItems,
  wayland,
  gtk3,
  glib,
  gdk-pixbuf,
  fontconfig,
  libX11,
  webkitgtk_4_1,
  libsoup_3,
}: let
  hashes = builtins.fromJSON (builtins.readFile ./hashes.json);
in
  stdenv.mkDerivation {
    pname = "magpie-desktop";
    inherit (hashes) version;

    src = fetchurl {
      url = "https://usemagpie.ai/files/v${hashes.version}/magpie-linux-amd64";
      hash = hashes.desktop;
    };
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/yetone/magpie/v${hashes.version}/site/public/img/icon-256.png";
      hash = hashes.icon;
    };

    dontUnpack = true;
    nativeBuildInputs = [autoPatchelfHook wrapGAppsHook3 copyDesktopItems];
    buildInputs = [wayland gtk3 glib gdk-pixbuf fontconfig libX11 webkitgtk_4_1 libsoup_3];
    desktopItems = [
      (makeDesktopItem {
        name = "magpie";
        desktopName = "Magpie";
        exec = "magpie-desktop";
        icon = "magpie";
        categories = ["Utility"];
      })
    ];
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/magpie-desktop"
      install -Dm644 "$icon" "$out/share/icons/hicolor/256x256/apps/magpie.png"
      runHook postInstall
    '';

    meta = {
      description = "Magpie desktop model gateway";
      homepage = "https://github.com/yetone/magpie";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "magpie-desktop";
    };
  }
