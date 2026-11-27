{
  flake.modules.nixos.trent =
    # NixOS account shared by standalone and imported hosts.
    let
      user = import ./trent/_identity.nix;
    in {
      imports = [./trent/_ssh-keys.nix];

      users.users.${user.name} = {
        isNormalUser = true;
        description = user.fullName;
        extraGroups = ["wheel"];
      };
    };
  flake.modules.homeManager.trent =
    # Shared Home Manager configuration for Trent on every managed home.
    {...}: let
      user = import ./trent/_identity.nix;
      identity = {
        name = user.fullName;
        inherit (user) email;
      };
    in {
      programs.git.settings.user = identity;
      programs.jujutsu.settings.user = identity;
      home = {
        username = user.name;
        homeDirectory = user.home;
        stateVersion = "26.11";
      };
    };
}
