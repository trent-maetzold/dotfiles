# The `user` account (host flake specialArgs), with nushell as login shell.
{
  pkgs,
  user,
  ...
}: {
  users.users.${user.name} = {
    isNormalUser = true;
    inherit (user) home;
    shell = pkgs.nushell;
    extraGroups = ["wheel"];
  };
}
