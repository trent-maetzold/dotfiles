# Magpie gateway on 127.0.0.1:3425 and its browser UI on 127.0.0.1:3430, from its
# upstream image (runs as uid 65532, HOME=/config/home). Rootless user unit; needs
# the NixOS quadlet.nix generator. Each agent's module mounts its own config dir
# under /config/home so magpie finds its sign-ins.
{
  config,
  lib,
  pkgs,
  quadlet-nix,
  ...
}: let
  home = config.home.homeDirectory;
in {
  imports = [quadlet-nix.homeManagerModules.quadlet];

  # CLI for `magpie provider add …` etc. on the host.
  home.packages = [pkgs.magpie-cli];

  # A fixed UI key keeps the browser signed in across restarts (cookie lasts 400
  # days). First sign-in: the link in `journalctl --user -u magpie`.
  home.activation.magpieWebKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    env=${home}/.config/magpie/web.env
    if [ ! -e "$env" ]; then
      mkdir -p "$(dirname "$env")"
      (umask 077; echo "MAGPIE_WEB_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 16)" > "$env")
    fi
  '';

  virtualisation.quadlet.containers.magpie = {
    autoStart = true;
    containerConfig = {
      image = "ghcr.io/yetone/magpie:latest";
      # Host network: callers arrive from loopback, which magpie trusts without a gateway key.
      networks = ["host"];
      environments.MAGPIE_ADDR = "127.0.0.1:3425";
      environmentFiles = ["${home}/.config/magpie/web.env"];
      exec = "web --addr 127.0.0.1:3430 --no-open";
      userns = "keep-id:uid=65532,gid=65532";
      volumes = [
        "magpie:/config"
        "${home}/.config/magpie:/config/magpie"
      ];
    };
    # WSL has no network-online target for Quadlet's user wait helper.
    quadletConfig.defaultDependencies = false;
  };
}
