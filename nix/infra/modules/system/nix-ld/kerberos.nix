# Kerberos (MIT krb5) for unpatched binaries (nix-ld).
let
  modules.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.krb5.dev];

    programs.nix-ld.libraries = [pkgs.krb5.lib];
  };
in {
  # Flake Modules
  flake.modules.nixos.nix-ld-kerberos = modules.nixos;
}
