# trent's Home Manager config on muninn: every dotfiles home module, the
# desktop ones (Niri, Noctalia, Zen, ...), and muninn's display scaling.
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

  wayland.windowManager.niri.settings._children = [
    {
      output = {
        _args = ["eDP-1"];
        scale = 1.5;
      };
    }
  ];
}
