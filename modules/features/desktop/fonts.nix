{flake.modules.nixos.os-desktop-fonts = {pkgs, ...}: {
  fonts.packages = with pkgs; [noto-fonts noto-fonts-color-emoji nerd-fonts.jetbrains-mono];
};}
