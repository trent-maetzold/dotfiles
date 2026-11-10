# Podman, plus the quadlet generator for rootless containers declared in Home
# Manager (home/ai/magpie.nix).
{quadlet-nix, ...}: {
  imports = [quadlet-nix.nixosModules.quadlet];
  virtualisation.podman.enable = true;
  virtualisation.quadlet.enable = true;
}
