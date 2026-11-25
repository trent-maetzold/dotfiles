# Shared Home Manager configuration for Trent on every managed home.
{self, ...}: let
  user = import ./identity.nix;
in {
  imports = [self.homeModules.default];

  home = {
    username = user.name;
    homeDirectory = user.home;
    stateVersion = "26.11";
  };
}
