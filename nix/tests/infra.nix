# Run with: nix eval --impure --json --expr
# 'import ./nix/tests/infra.nix { flake = builtins.getFlake (toString ./.); }'
{flake}: let
  lib = flake.inputs.nixpkgs.lib;
  hosts = lib.genAttrs ["heimdall" "yggdrasil" "frigg"] (n: flake.nixosConfigurations.${n}.config);
  h = hosts.heimdall;
  y = hosts.yggdrasil;
  f = hosts.frigg;
  serials = [
    "S59CNM0W619880X"
    "S59CNM0W538791D"
    "S59CNM0W518854F"
    "S59CNM0W518856Z"
    "S59CNM0W619589N"
    "S59CNM0W619882P"
    "S59CNM0W619751J"
  ];
  zfsDisk = n: serial: let
    d = y.disko.devices.disk."nvme${toString n}";
  in
    d.device
    == "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_${serial}"
    && d.content.partitions.esp.size == "1G"
    && d.content.partitions.esp.label == "esp${toString n}"
    && d.content.partitions.esp.content.mountpoint
    == (
      if n == 0
      then "/boot/efi"
      else null
    )
    && d.content.partitions.zfs.content.pool == "tank";
  checks = {
    platforms =
      h.nixpkgs.hostPlatform.system
      == "aarch64-linux"
      && y.nixpkgs.hostPlatform.system == "x86_64-linux"
      && f.nixpkgs.hostPlatform.system == "x86_64-linux";
    stateVersions = lib.all (c: c.system.stateVersion == "26.11") (builtins.attrValues hosts);
    comin = lib.all (c: let
      rs = c.services.comin.remotes;
      r = builtins.head rs;
    in
      c.services.comin.enable
      && builtins.length rs == 1
      && r.name == "origin"
      && r.url == "https://github.com/trent-maetzold/dotfiles.git"
      && r.branches.main.name == "staging"
      && r.branches.main.operation == "switch")
    (builtins.attrValues hosts);
    heimdallMounts =
      h.fileSystems."/".device
      == "/dev/disk/by-label/nixos"
      && h.fileSystems."/".fsType == "ext4"
      && h.fileSystems."/".autoResize
      && h.fileSystems."/boot".device == "/dev/disk/by-label/ESP";
    yggdrasilDisks = lib.all (v: v) (lib.imap0 zfsDisk serials);
    yggdrasilPool =
      y.networking.hostId
      == "6d8a7c3f"
      && y.disko.devices.zpool.tank.mode == "raidz2"
      && y.disko.devices.zpool.tank.rootFsOptions.recordsize == "1M";
    friggLayout =
      f.disko.devices.disk.main.device
      == "/dev/nvme0n1"
      && f.disko.devices.disk.main.content.partitions.esp.size == "4G"
      && f.disko.devices.disk.main.content.partitions.root.content.type == "btrfs"
      && f.disko.devices.nodev."/".mountOptions == ["size=2G" "mode=755"];
    cominPersistence =
      lib.any (d: d.directory == "/var/lib/comin") f.preservation.preserveAt."/persist".directories
      && builtins.hasAttr "/var/lib/comin" f.persistence.dirs
      && !(y.persistence.dirs."/var/lib/comin".snapshots);
    friggPackages = let
      fuses = lib.filter (p: lib.getName p == "fuse") f.environment.systemPackages;
    in
      fuses
      != []
      && lib.all (p: lib.versions.major p.version == "3") fuses
      && f.services.flatpak.enable
      && f.security.wrappers.fusermount3.setuid
      && !(builtins.hasAttr "fusermount" f.security.wrappers)
      && lib.any (p: lib.getName p == "superlight") f.environment.cinnamon.excludePackages;
    standaloneNix = lib.all (name: let
      n = flake.nixosConfigurations.${name};
      c = n.config;
      p = n.pkgs;
      has = packages: package: lib.any (v: toString v == toString package) packages;
    in
      c.programs.nix-ld.enable
      && lib.elem "https://cache.numtide.com" (c.nix.settings.extra-substituters or [])
      && lib.elem "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" (c.nix.settings.extra-trusted-public-keys or [])
      && lib.all (has c.programs.nix-ld.libraries) [p.zlib p.stdenv.cc.cc p.libpq p.krb5.lib]
      && lib.all (has c.environment.systemPackages) [p.libpq.pg_config p.krb5.dev]) ["muninn" "sif"];
    existingHosts = lib.all builtins.isString [
      flake.nixosConfigurations.muninn.config.system.build.toplevel.drvPath
      flake.nixosConfigurations.sif.config.system.build.toplevel.drvPath
      flake.apps.x86_64-linux.bootstrap.program
    ];
    ageKeys = lib.all (c: c.sops.age.keyFile == "/var/lib/age/key.txt") (builtins.attrValues hosts);
    publicHosts = builtins.attrNames flake.nixosConfigurations == ["frigg" "heimdall" "muninn" "sif" "yggdrasil"];
  };
in
  assert lib.assertMsg (lib.all (v: v) (builtins.attrValues checks))
  "Infrastructure migration invariant failed: ${lib.concatStringsSep ", " (builtins.attrNames (lib.filterAttrs (_: v: !v) checks))}"; checks
