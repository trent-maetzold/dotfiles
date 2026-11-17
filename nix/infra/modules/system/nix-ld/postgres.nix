# PostgreSQL's libpq for unpatched binaries (nix-ld).
let
  modules.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.libpq.pg_config];

    programs.nix-ld.libraries = [pkgs.libpq];
  };
in {
  # Flake Modules
  flake.modules.nixos.nix-ld-postgres = modules.nixos;
}
