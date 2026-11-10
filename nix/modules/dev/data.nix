# Database TUIs: harlequin (SQL), tredis (Redis). Connections come from the system flake.
{pkgs, ...}: {
  home.packages = with pkgs; [harlequin tredis];
}
