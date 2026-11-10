# Magpie gateway (127.0.0.1:3425) as a rootless Podman Quadlet. The host needs
# quadlet-nix's NixOS module with virtualisation.quadlet.enable = true.
{
  config,
  pkgs,
  quadlet-nix,
  ...
}: let
  magpie = pkgs.magpie-cli;
  home = config.home.homeDirectory;
  image = pkgs.dockerTools.buildLayeredImage {
    name = "localhost/magpie";
    tag = "latest";
    contents = [magpie pkgs.bashInteractive pkgs.coreutils];
    # Magpie downloads its own Bun for plugins; give that glibc binary a loader.
    extraCommands = ''
      mkdir -p lib64 tmp && chmod 1777 tmp
      ln -s ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 lib64/
    '';
    config.Cmd = ["magpie" "serve"];
  };
  # Same paths inside as outside, so paths magpie writes into configs stay valid.
  dirs = map (d: "${home}/${d}") [".config/magpie" ".cache/magpie" ".codex" ".pi"];
in {
  imports = [quadlet-nix.homeManagerModules.quadlet];

  home.packages = [magpie];

  virtualisation.quadlet.containers.magpie = {
    autoStart = true;
    containerConfig = {
      image = "docker-archive:${image}";
      networks = ["host"];
      userns = "keep-id";
      workdir = home;
      environments = {
        HOME = home;
        SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      };
      volumes = ["/etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro"] ++ map (d: "${d}:${d}") dirs;
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 5;
    };
    # WSL has no host network-online target for Quadlet's user wait helper.
    quadletConfig.defaultDependencies = false;
  };
}
