# The `~/.local/bin/<name>` file entering distrobox container <name>, creating it if missing.
{pkgs}: name: {
  executable = true;

  text = ''
    #!${pkgs.bash}/bin/bash

    # Self-heal: home-manager records its hash even when create fails.
    if ! distrobox list 2>/dev/null | awk -F'|' 'NR>1 {gsub(/[[:space:]]/, "", $2); if ($2 == "${name}") found=1} END {exit !found}'; then
      distrobox-assemble create --file "$HOME/.config/distrobox/containers.ini"
    fi

    if [ $# -gt 0 ]; then
      distrobox enter ${name} -- "$@"
    else
      distrobox enter ${name}
    fi
  '';
}
