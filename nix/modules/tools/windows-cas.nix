{ pkgs, ... }:
{
  home.packages = [ (pkgs.callPackage ../../pkgs/export-windows-cas.nix { }) ];
}
