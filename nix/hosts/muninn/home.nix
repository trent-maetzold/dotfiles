# trent's Home Manager config on muninn: every dotfiles home module (Niri's
# bindings come from desktop/niri.nix), plus muninn's display scaling.
{
  config,
  self,
  ...
}: {
  imports = [self.homeModules.default];

  home = {
    username = "trent";
    homeDirectory = "/home/trent";
    stateVersion = "26.11";
  };

  # `nh os switch` builds this checkout.
  programs.nh.flake = "${config.home.homeDirectory}/.config/dotfiles";

  xdg.configFile."niri/config.kdl".text = ''
    output "eDP-1" {
      scale 1.5
    }
  '';
}
