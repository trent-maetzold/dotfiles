# Shared Home Manager configuration for Trent on every managed home.
{...}: let
  user = import ./identity.nix;
in {
  home = {
    username = user.name;
    homeDirectory = user.home;
    stateVersion = "26.11";
  };
}
