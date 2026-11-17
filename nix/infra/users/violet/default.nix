# violet: family desktop with Roblox Studio; logs in without a password.
{config, ...}: let
  inherit (config.flake) homeModules;
in {
  flake.users.violet = config.flake.lib.makeUser {
    name = "violet";
    hashedPassword = "";
    groups = ["kids"];
    imports = [
      homeModules.violet
      homeModules.kids
    ];
  };

  flake.homeModules.violet = {};
}
