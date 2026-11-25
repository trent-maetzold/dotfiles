{config, ...}: {
  flake.modules.nixos.admin =
    # trent administers every standalone machine. Bootstrap sets the first
    # password; change it with `passwd`.
    {
      imports = [config.flake.modules.nixos.trent];

      users.users.trent.extraGroups = ["networkmanager"];
    };
}
