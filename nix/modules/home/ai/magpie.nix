# Magpie on the host: gateway on 127.0.0.1:3425, browser UI on 127.0.0.1:3430.
# Runs as us, so it reads every agent's config and sign-ins directly.
{
  config,
  lib,
  pkgs,
  ...
}: let
  env = "${config.xdg.configHome}/magpie/web.env";
in {
  home.packages = [pkgs.magpie-cli];

  # A fixed UI key keeps the browser signed in across restarts (cookie lasts 400
  # days). First sign-in: the link in `journalctl --user -u magpie`.
  home.activation.magpieWebKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -e "${env}" ]; then
      mkdir -p "$(dirname "${env}")"
      (umask 077; echo "MAGPIE_WEB_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 16)" > "${env}")
    fi
  '';

  systemd.user.services.magpie = {
    Unit.Description = "Magpie model gateway";
    Service = {
      Environment = ["MAGPIE_ADDR=127.0.0.1:3425"];
      EnvironmentFile = env;
      ExecStart = "${lib.getExe pkgs.magpie-cli} web --addr 127.0.0.1:3430 --no-open";
      Restart = "on-failure";
    };
    Install.WantedBy = ["default.target"];
  };
}
