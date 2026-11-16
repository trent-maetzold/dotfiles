# Graphical pinentry (rbw, gpg) on desktops, over the terminal one.
{
  lib,
  pkgs,
  ...
}: {
  home.packages = [(lib.hiPrio pkgs.pinentry-qt)];
}
