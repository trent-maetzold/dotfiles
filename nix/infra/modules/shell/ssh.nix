# SSH: a strict client config, and an OpenSSH server with keys only and no
# root login.
{config, ...}: let
  modules.homeManager = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "no";
        Compression = false;
        ForwardAgent = false;
        HashKnownHosts = false;
        ServerAliveCountMax = 3;
        ServerAliveInterval = 0;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };

  modules.nixos = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.ssh = modules.homeManager;
  flake.modules.nixos.ssh = modules.nixos;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.ssh];
  flake.homeModules.default-slim.imports = [config.flake.modules.homeManager.ssh];

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.ssh];
}
