{
  flake.modules.homeManager.dev-data =
    # Database TUIs: harlequin (SQL), tredis (Redis). Connections are per project.
    {pkgs, ...}: {
      home.packages = with pkgs; [harlequin tredis];
    };
}
