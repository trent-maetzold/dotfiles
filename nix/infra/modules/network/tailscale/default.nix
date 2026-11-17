# Tailscale, joined to this flake's headscale; the tailnet interface is
# trusted, and routes other hosts advertise are accepted. `tailscale-auth` also
# logs in with the `ts-authkey` file; `tailscale-subnet-router` routes the
# tailnet to `tailscale.subnetRoutes`, NATed out of `networking.nat.externalInterface`.
{config, ...}: let
  modules.nixos = {tailnet, ...}: {
    networking.firewall.trustedInterfaces = ["tailscale0"];

    services.tailscale = {
      enable = true;
      extraUpFlags = ["--login-server=${tailnet.loginServer}"];
      extraSetFlags = ["--netfilter-mode=off" "--accept-routes"];
    };
  };

  modules.nixos-auth = {ts-authkey, ...}: {
    imports = [modules.nixos];

    services.tailscale.authKeyFile = ts-authkey;
  };

  modules.nixos-subnet-router = {
    config,
    lib,
    ...
  }: {
    services.tailscale = {
      useRoutingFeatures = "server";
      # Repeated flags keep only the last, so every route goes in one.
      extraSetFlags = ["--advertise-routes=${lib.concatStringsSep "," config.tailscale.subnetRoutes}"];
    };

    networking.nat = {
      enable = true;
      internalInterfaces = ["tailscale0"];
    };
  };

  # This flake's tailnet key.
  authkey = {config, ...}: {
    sops.secrets.ts-authkey.key = "tailscale/ts-authkey";
    _module.args.ts-authkey = config.sops.secrets.ts-authkey.path;
  };
in {
  # Flake Modules
  flake.modules.nixos.tailscale = modules.nixos;
  flake.modules.nixos.tailscale-auth = modules.nixos-auth;
  flake.modules.nixos.tailscale-subnet-router = modules.nixos-subnet-router;

  # NixOS Configuration Modules
  flake.nixosModules = {
    frigg.imports = [config.flake.modules.nixos.tailscale-auth authkey];
    heimdall.imports = [config.flake.modules.nixos.tailscale-auth authkey];
    thor.imports = [config.flake.modules.nixos.tailscale-auth authkey];
    yggdrasil.imports = [
      config.flake.modules.nixos.tailscale-auth
      authkey
      config.flake.modules.nixos.tailscale-subnet-router
      {networking.nat.externalInterface = "br0";}
    ];
  };
}
