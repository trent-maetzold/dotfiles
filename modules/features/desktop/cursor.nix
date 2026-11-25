{
  flake.modules.homeManager.desktop-cursor =
    # A shared cursor theme for desktop applications.
    {pkgs, ...}: {
      home.pointerCursor = {
        enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Original-Ice";
        size = 32;
      };
    };
}
