# trent's Home Manager config on muninn: every dotfiles home module and the
# desktop ones (Umbriel, Noctalia, Zen, ...).
{self, ...}: {
  imports = [
    self.homeModules.default
    self.homeModules.desktop
  ];

  home = {
    username = "trent";
    homeDirectory = "/home/trent";
    stateVersion = "26.11";
  };
}
