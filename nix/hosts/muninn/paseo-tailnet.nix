{pkgs, ...}: let
  # Check the running daemon on each connection, not just at proxy startup:
  # editing Paseo's config does not apply a password until it is restarted.
  forward = pkgs.writeShellScript "paseo-tailnet-forward" ''
    status="$(${pkgs.curl}/bin/curl --silent --output /dev/null --write-out '%{http_code}' --max-time 5 http://127.0.0.1:6767/api/status)" || exit 1
    if [ "$status" != 401 ]; then
      echo 'Paseo password authentication is not active; refusing tailnet connection' >&2
      exit 1
    fi
    exec ${pkgs.socat}/bin/socat - TCP4:127.0.0.1:6767
  '';
  listen = pkgs.writeShellScript "paseo-tailnet-listen" ''
    address="$(${pkgs.tailscale}/bin/tailscale ip -4)"
    if [ -z "$address" ]; then
      echo 'No Tailscale IPv4 address available' >&2
      exit 1
    fi
    exec ${pkgs.socat}/bin/socat "TCP4-LISTEN:6767,bind=$address,reuseaddr,fork" EXEC:${forward}
  '';
in {
  systemd.user.services.paseo-tailnet = {
    Unit = {
      Description = "Tailnet-only proxy for the local Paseo daemon";
      StartLimitIntervalSec = 0;
      After = ["paseo.service"];
      Wants = ["paseo.service"];
      PartOf = ["paseo.service"];
    };
    Service = {
      ExecStart = listen;
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = ["default.target" "paseo.service"];
  };
}
