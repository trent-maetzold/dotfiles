# NixOS account shared by standalone and imported hosts.
let
  user = import ./identity.nix;
in {
  imports = [./ssh-keys.nix];

  users.users.${user.name} = {
    isNormalUser = true;
    description = user.fullName;
    extraGroups = ["wheel"];
  };
}
