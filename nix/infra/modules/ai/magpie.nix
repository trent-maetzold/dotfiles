# magpie model gateway and its web UI in one quadlet container, on loopback;
# on yggdrasil on its tailnet IP for the router, at magpie.ts.trkm.io. State is
# files in its `/config` volume; no database. `magpie-web-key` is the web UI
# key's file.
{
  config,
  quadlet-nix,
  ...
}: let
  inherit (config.flake.lib) makeEnvFile makeServiceRoute;

  port = 3430;

  modules.nixos = {
    config,
    lib,
    pkgs,
    magpie-web-key,
    ...
  }: let
    env = makeEnvFile {
      inherit pkgs;
      name = "magpie";
      vars.MAGPIE_WEB_KEY = magpie-web-key;
    };
  in {
    imports = [quadlet-nix.nixosModules.quadlet];

    virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      volumes.magpie = {};

      containers.magpie = {
        serviceConfig = {
          inherit (env) ExecStartPre;
          Restart = "always";
        };

        containerConfig = {
          name = "magpie";
          image = lib.mkDefault "ghcr.io/yetone/magpie:latest";
          environmentFiles = [env.file];
          volumes = ["${config.virtualisation.quadlet.volumes.magpie.ref}:/config"];
          exec = "web --addr 0.0.0.0:${toString port} --no-open";
          # Podman's DNAT skips the host firewall: publish on one address only.
          publishPorts = lib.mkDefault ["127.0.0.1:${toString port}:${toString port}"];
        };
      };
    };
  };

  route = makeServiceRoute {
    hostname = "magpie.ts.trkm.io";
    ip = config.hosts.yggdrasil.ips.tailnet;
    inherit port;
  };

  hosts.yggdrasil = {config, ...}: {
    sops.secrets.magpie-web-key.key = "magpie/web-key";
    _module.args.magpie-web-key = config.sops.secrets.magpie-web-key.path;

    # Volumes, not the image store.
    persistence.dirs."/var/lib/containers/storage/volumes".snapshots = true;

    virtualisation.quadlet.containers.magpie.containerConfig = {
      publishPorts = ["${route.endpoint.ip}:${toString port}:${toString port}"];
      environments.MAGPIE_PUBLIC_URL = "https://${route.hostname}";
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.magpie = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.magpie
    config.flake.modules.nixos.quadlet
    hosts.yggdrasil
  ];

  # Routes
  routes.magpie = route;
}
