# Context7 CLI: current library docs for agents. Works without an API key.
{ pkgs, ... }:
{
  home.packages = [ (pkgs.callPackage ../../pkgs/ctx7 { }) ];
}
