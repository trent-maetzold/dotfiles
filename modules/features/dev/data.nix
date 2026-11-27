{inputs, ...}: {
  flake.modules.homeManager.data =
    # Database TUIs: harlequin (SQL), tredis (Redis). Connections are per project.
    {pkgs, ...}: {
      home.packages = [pkgs.harlequin (inputs.zoldt-pkgs.modules.overlays.default pkgs pkgs).tredis];
    };
}
