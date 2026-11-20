# sops, and the ssh-to-age that turns a host key into the age recipient the
# per-host secrets.yaml files are encrypted to.
{pkgs, ...}: {
  home.packages = [pkgs.sops pkgs.ssh-to-age];
}
