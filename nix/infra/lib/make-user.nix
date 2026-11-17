# A user. `imports` carries the profiles (`asgard.homeModules.*`) and plain
# home modules. The rest is glue that applies only where a feature already
# enabled the program; `hosts` (makeHost results) become ssh client entries.
# `specialArgs` reach its home modules. An `initialPassword` must be changed at
# first login.
{
  config,
  home-manager,
  lib,
  nixpkgs,
  ...
}: {
  flake.lib.makeUser = {
    name,
    imports ? [],
    groups ? [],
    shell ? null,
    publicKeys ? [],
    git ? null,
    hosts ? {},
    specialArgs ? {},
    hashedPassword ? null,
    initialPassword ? null,
  }: let
    homeModule = {config, ...}: {
      inherit imports;

      home.username = name;

      programs = {
        git.settings.user = lib.mkIf (config.programs.git.enable && git != null) git;
        ssh.settings = lib.mkIf config.programs.ssh.enable (lib.concatMapAttrs (_: host: lib.mapAttrs (_: s: {User = name;} // s) host.ssh) hosts);
      };
    };
  in {
    inherit name homeModule;

    nixosModule = {
      config,
      pkgs,
      ...
    }: {
      imports = [home-manager.nixosModules.home-manager];

      home-manager = {
        users.${name} = homeModule;
        extraSpecialArgs = specialArgs;
      };

      # A login shell needs its NixOS module for /etc/shells and the system profile.
      programs = lib.optionalAttrs (shell != null) {${shell}.enable = true;};

      users.users.${name} = {
        isNormalUser = true;
        extraGroups = groups;
        openssh.authorizedKeys.keys = publicKeys;
        shell = lib.mkIf (shell != null) pkgs.${shell};
        hashedPassword = lib.mkIf (hashedPassword != null) hashedPassword;
        initialPassword = lib.mkIf (initialPassword != null) initialPassword;
      };

      # /var/lib/nixos holds user-creation state, so it outlives reboots wherever users do.
      systemd.services."expire-${name}-password" = lib.mkIf (initialPassword != null) {
        wantedBy = ["multi-user.target"];
        unitConfig.ConditionPathExists = "!/var/lib/nixos/expired-${name}";
        serviceConfig.Type = "oneshot";
        # shadow won't follow /etc/passwd when userborn links it elsewhere.
        script = "${pkgs.shadow}/bin/chage -P ${dirOf config.services.userborn.passwordFilesLocation} -d 0 ${name} && touch /var/lib/nixos/expired-${name}";
      };
    };

    homeConfiguration = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = lib.attrValues config.flake.overlays;
        };

        extraSpecialArgs = specialArgs;
        modules = [homeModule];
      };
  };
}
