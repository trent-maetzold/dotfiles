# Rootless quadlets (Home Manager units) need podman's user generator, and only
# NixOS can install generators. No system podman or root containers.
{pkgs, ...}: {
  systemd.user.generators.podman-user-generator = "${pkgs.podman}/lib/systemd/user-generators/podman-user-generator";
}
