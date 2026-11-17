# leo: family desktop with Roblox Studio; logs in without a password.
{config, ...}: let
  inherit (config.flake) homeModules;
in {
  flake.users.leo = config.flake.lib.makeUser {
    name = "leo";
    hashedPassword = "";
    groups = ["kids"];
    imports = [
      homeModules.leo
      homeModules.kids
    ];
  };

  flake.homeModules.leo = {};
}
