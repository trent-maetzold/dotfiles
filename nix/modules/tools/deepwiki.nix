# DeepWiki CLI: query DeepWiki docs for public GitHub repos. No auth.
{ pkgs, ... }:
{
  home.packages = [ (pkgs.callPackage ../../pkgs/deepwiki { }) ];
}
