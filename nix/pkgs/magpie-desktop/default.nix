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
}:
stdenv.mkDerivation {
  pname = "magpie-desktop";
  version = "0.1.3419";

  src = fetchurl {
    url = "https://usemagpie.ai/files/v0.1.3419/magpie-linux-amd64";
    hash = "sha256-n/GhmBqUhTyV/X6QQpA+TJtN39LgPBpf0xEs5oQOM2g=";
  };

  dontUnpack = true;
  nativeBuildInputs = [autoPatchelfHook wrapGAppsHook3 copyDesktopItems];
  buildInputs = [wayland gtk3 glib gdk-pixbuf fontconfig libX11 webkitgtk_4_1 libsoup_3];
  desktopItems = [
    (makeDesktopItem {
      name = "magpie";
      desktopName = "Magpie";
      exec = "magpie-desktop";
      categories = ["Utility"];
    })
  ];
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/magpie-desktop"
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
