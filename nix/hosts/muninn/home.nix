# trent's Home Manager config on muninn: every dotfiles home module and the
# desktop ones (Umbriel, Noctalia, Zen, ...).
{self, ...}: {
  imports = [
    ../../users/trent
    self.homeModules.desktop
    ./paseo-tailnet.nix
  ];

  programs.umbriel.settings.output."eDP-1".scale = 1.4;
}
