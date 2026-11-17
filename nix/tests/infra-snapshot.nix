# Evaluate purely: the legacy LazyVim resolver otherwise scans the evaluator's
# live home directory, which is not part of a host's declarative configuration.
{
  nixpkgs,
  configurations,
}: let
  lib = nixpkgs.lib;
  normalize = v:
    if !(builtins.tryEval v).success
    then "<unavailable-option>"
    else if builtins.isFunction v
    then "<function>"
    else if lib.isDerivation v
    then toString v
    else if builtins.isPath v
    then toString v
    else if builtins.isList v
    then map normalize v
    else if builtins.isAttrs v
    then lib.mapAttrs (_: normalize) (lib.filterAttrs (n: _: !(lib.hasPrefix "_" n)) v)
    else v;
  packages = ps:
    map (p: {
      name = p.pname or (lib.getName p);
      version = p.version or "";
    })
    ps;
  enabled = lib.filterAttrs (_: s: builtins.isAttrs s && (s.enable or false) == true);
  snapshot = n: let
    c = n.config;
  in
    normalize {
      host = c.networking.hostName;
      system = c.nixpkgs.hostPlatform.system;
      stateVersion = c.system.stateVersion;
      packages = packages c.environment.systemPackages;
      networking = c.networking;
      boot = {
        inherit (c.boot) kernelParams blacklistedKernelModules kernelModules supportedFilesystems;
        loader = {
          inherit (c.boot.loader.efi) canTouchEfiVariables;
          grub = {inherit (c.boot.loader.grub) enable devices efiSupport efiInstallAsRemovable;};
          systemd-boot = {inherit (c.boot.loader.systemd-boot) enable configurationLimit editor;};
        };
        initrd = {
          inherit (c.boot.initrd) availableKernelModules kernelModules;
          luks = c.boot.initrd.luks.devices;
        };
      };
      fileSystems = c.fileSystems;
      swapDevices = c.swapDevices;
      disko = c.disko.devices or {};
      persistence = c.persistence or {};
      preservation = c.preservation or {};
      users = c.users.users;
      groups = c.users.groups;
      services = enabled c.services;
      units =
        lib.mapAttrs (_: s: {
          inherit
            (s)
            enable
            unitConfig
            serviceConfig
            environment
            script
            preStart
            postStart
            preStop
            postStop
            after
            before
            requires
            wants
            wantedBy
            bindsTo
            partOf
            path
            restartTriggers
            ;
        })
        c.systemd.services;
      sockets = c.systemd.sockets;
      timers = c.systemd.timers;
      security = {inherit (c.security) sudo polkit rtkit pam;};
      nix = {inherit (c.nix) settings gc optimise;};
      environment = {inherit (c.environment) etc variables sessionVariables shells;};
      sops = lib.mapAttrs (_: s: {inherit (s) key path owner group mode sopsFile;}) c.sops.secrets;
      homes =
        lib.mapAttrs (_: h: {
          stateVersion = h.home.stateVersion;
          packages = packages h.home.packages;
          files = h.home.file;
          activation = lib.mapAttrs (_: a: a.data) h.home.activation;
          programs = enabled h.programs;
          services = enabled h.services;
          systemd = h.systemd.user;
          variables = h.home.sessionVariables;
          paths = h.home.sessionPath;
        })
        c.home-manager.users;
    };
in
  lib.mapAttrs (_: snapshot) (builtins.intersectAttrs {
      heimdall = null;
      yggdrasil = null;
      frigg = null;
    }
    configurations)
