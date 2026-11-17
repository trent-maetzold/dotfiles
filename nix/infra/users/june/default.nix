# june: family desktop with Roblox Studio; logs in without a password.
{config, ...}: let
  inherit (config.flake) homeModules;
in {
  flake.users.june = config.flake.lib.makeUser {
    name = "june";
    hashedPassword = "";
    groups = ["kids"];
    imports = [
      homeModules.june
      homeModules.kids
    ];
  };

  flake.homeModules.june = {};
}
