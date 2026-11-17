# Distrobox with `bx`, a uv Debian build container able to build psycopg2 and gssapi.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: let
    makeDistroboxWrapper = import ./_lib/make-distrobox-wrapper.nix {inherit pkgs;};

    containerfile = pkgs.writeTextDir "Containerfile" ''
      FROM ghcr.io/astral-sh/uv:trixie
      RUN apt-get update && apt-get install -y --no-install-recommends libkrb5-dev libpq-dev python3-dev && rm -rf /var/lib/apt/lists/*
    '';
  in {
    agents.md.tools = ["- `bx`: Debian distrobox with uv, build tools, libpq, krb5 and Python headers, for builds needing distro packages: `bx <cmd>`."];

    home.file = {
      ".local/bin/bx" = makeDistroboxWrapper "bx";
      ".local/bin/distrobox-export".source = "${pkgs.distrobox}/bin/distrobox-export";
      ".local/bin/distrobox-host-exec".source = "${pkgs.distrobox}/bin/distrobox-host-exec";
    };

    # Tagged localhost/homemanager/bx; the wrapper creates the container on first use.
    services.podman.builds.bx = {
      file = "${containerfile}/Containerfile";
      workingDirectory = "${containerfile}";
    };

    programs.distrobox = {
      enable = true;
      # Its unit can't find a home-manager podman.
      enableSystemdUnit = false;

      containers.bx = {
        image = "localhost/homemanager/bx";
        entry = true;
        volume = "/etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro";
      };

      settings.container_manager = "podman";
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.distrobox = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.distrobox];
}
