# trent administers every standalone machine. Bootstrap sets the first
# password; change it with `passwd`.
{
  imports = [../../../users/trent/nixos.nix];

  users.users.trent.extraGroups = ["networkmanager"];
}
