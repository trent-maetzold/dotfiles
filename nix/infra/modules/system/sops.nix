# Secrets: sops-nix decrypts the `secrets` file with the host's own age key;
# you edit it with the age master key from Bitwarden.
{config, ...}: let
  modules.nixos = {
    sops-nix,
    secrets,
    ...
  }: {
    imports = [sops-nix.nixosModules.sops];

    sops = {
      defaultSopsFile = secrets;

      age = {
        keyFile = "/var/lib/age/key.txt";
        sshKeyPaths = [];
      };

      gnupg.sshKeyPaths = [];
    };

    persistence.files."/var/lib/age/key.txt".mode = "0400";
  };

  modules.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.sops];
    home.sessionVariables.SOPS_AGE_KEY_CMD = "rbw get age-master";
  };
in {
  # Flake Modules
  flake.modules = {
    nixos.sops = modules.nixos;
    homeManager.sops = modules.homeManager;
  };

  # NixOS Configuration Modules
  flake.nixosModules = {
    frigg.imports = [config.flake.modules.nixos.sops];
    heimdall.imports = [config.flake.modules.nixos.sops];
    thor.imports = [config.flake.modules.nixos.sops];
    yggdrasil.imports = [config.flake.modules.nixos.sops];
  };

  # Home Configuration Modules
  flake.homeModules.infra.imports = [config.flake.modules.homeManager.sops];
}
