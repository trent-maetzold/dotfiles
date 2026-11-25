# Expose Heimdall's headscale CLI and completions over SSH. Privileged
# commands require an explicit local sudo, which is forwarded to Heimdall.
{
  lib,
  pkgs,
}:
  pkgs.runCommandLocal "headscale-remote" {
    nativeBuildInputs = [pkgs.installShellFiles];
  } ''
    mkdir -p $out/bin
    cat > $out/bin/headscale <<'EOF'
    #!${pkgs.runtimeShell}
    set -eu

    # Forward sudo only when invoked through it locally (euid 0). Plain
    # invocations, including the completion calls, run headscale as the remote
    # user.
    if [ "$(${pkgs.coreutils}/bin/id -u)" -eq 0 ]; then
      remote="sudo -n headscale"
      # Do the ssh as the invoking user so it uses their agent, keys and
      # known_hosts; sudo has already stripped HOME and SSH_AUTH_SOCK.
      if [ -n "''${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ]; then
        uid="''${SUDO_UID:-$(${pkgs.coreutils}/bin/id -u "$SUDO_USER")}"
        home="$(${pkgs.getent}/bin/getent passwd "$SUDO_USER" | ${pkgs.coreutils}/bin/cut -d: -f6)"
        ssh=("${pkgs.util-linux}/bin/runuser" -u "$SUDO_USER" --
          ${pkgs.coreutils}/bin/env "HOME=$home" "XDG_RUNTIME_DIR=/run/user/$uid"
          ${lib.getExe pkgs.openssh})
      else
        ssh=(${lib.getExe pkgs.openssh})
      fi
    else
      remote=headscale
      ssh=(${lib.getExe pkgs.openssh})
    fi

    # ssh joins its arguments with spaces and lets the remote shell reparse
    # them, so quote each one to preserve argv (spaces, globs, empty strings).
    cmd="$remote"
    for arg in "$@"; do
      cmd="$cmd $(printf '%q' "$arg")"
    done
    exec "''${ssh[@]}" trent@hs.trkm.io "$cmd"
    EOF
    chmod +x $out/bin/headscale

    installShellCompletion --cmd headscale \
      --bash ${pkgs.headscale}/share/bash-completion/completions/headscale.bash \
      --fish ${pkgs.headscale}/share/fish/vendor_completions.d/headscale.fish \
      --zsh ${pkgs.headscale}/share/zsh/site-functions/_headscale

    install -Dm644 ${./headscale.nu} $out/share/nushell/vendor/autoload/headscale.nu
  ''
