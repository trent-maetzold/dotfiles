# trent's Home Manager config on muninn: every dotfiles home module (Niri's
# bindings come from desktop/niri.nix), plus muninn's display scaling.
{self, ...}: {
  imports = [self.homeModules.default];

  home = {
    username = "trent";
    homeDirectory = "/home/trent";
    stateVersion = "26.11";
  };

  xdg.configFile."niri/config.kdl".text = ''
    output "eDP-1" {
      scale 1.5
    }
  '';
}
