# openwiki CLI. The pi extension is installed separately by pi
# ("npm:openwiki" in config/pi/agent/settings.json).
{ pkgs, ... }:
{
  home.packages = [ (pkgs.callPackage ../../pkgs/openwiki { }) ];
}
