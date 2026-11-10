{pkgs, ...}: {
  # Provider for `podman compose`, found on PATH.
  home.packages = with pkgs; [podman-compose];

  programs.lazydocker.enable = true;
}
