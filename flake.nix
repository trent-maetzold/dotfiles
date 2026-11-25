{
  description = "Home Manager dotfiles";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
    {inherit inputs;}
    (inputs.import-tree ./modules);

  inputs = {
    # Core
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    import-tree.url = "github:denful/import-tree";

    # Hosts (nix/hosts)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    # GitOps: standalone hosts pull this repo and switch themselves.
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Git-sourced k3s bootstrap manifests; update through the flake lock.
    homelab = {
      url = "github:trent-maetzold/homelab";
      flake = false;
    };

    # Imported host services and storage.
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    autolith.url = "github:lambda-symbolics/autolith";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-webui.url = "github:nesquena/hermes-webui";
    hermex-push = {
      url = "github:uzairansaruzi/hermex-push";
      flake = false;
    };
    honcho = {
      url = "github:plastic-labs/honcho";
      flake = false;
    };
    oh-my-hermes = {
      url = "github:rlaope/oh-my-hermes";
      flake = false;
    };
    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Modules (nix/modules/{home,nixos})
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    # Umbriel compositor; cachix tracks the latest commit CI cached, and no
    # nixpkgs follow so those store paths match (its installation guide).
    umbriel.url = "github:noctalia-dev/umbriel/cachix";

    # Packages
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Own nixpkgs (no follows) so packages hit the numtide binary cache.
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    llm-agents.url = "github:numtide/llm-agents.nix";
    # Noctalia community plugins, available for runtime plugin configuration.
    noctalia-plugins = {
      url = "github:noctalia-dev/community-plugins";
      flake = false;
    };
    bkt = {
      url = "github:avivsinai/bitbucket-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Python apps from uv.lock (nix/pkgs/keeper-cli)
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };
  };
}
