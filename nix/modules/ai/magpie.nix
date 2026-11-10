# Magpie gateway on 127.0.0.1:3425, from its upstream image (runs as uid 65532,
# HOME=/config/home). The host needs quadlet-nix's NixOS module enabled.
{
  config,
  pkgs,
  quadlet-nix,
  ...
}: let
  home = config.home.homeDirectory;
in {
  imports = [quadlet-nix.homeManagerModules.quadlet];

  # CLI for `magpie provider add …` etc. on the host.
  home.packages = [pkgs.magpie-cli];

  virtualisation.quadlet.containers.magpie = {
    autoStart = true;
    containerConfig = {
      image = "ghcr.io/yetone/magpie:latest";
      # Host network: callers arrive from loopback, which magpie trusts without a gateway key.
      networks = ["host"];
      environments.MAGPIE_ADDR = "127.0.0.1:3425";
      userns = "keep-id:uid=65532,gid=65532";
      volumes = [
        "magpie:/config"
        "${home}/.config/magpie:/config/magpie"
        "${home}/.codex:/config/home/.codex"
        "${home}/.pi:/config/home/.pi"
      ];
    };
    # WSL has no network-online target for Quadlet's user wait helper.
    quadletConfig.defaultDependencies = false;
  };
}
