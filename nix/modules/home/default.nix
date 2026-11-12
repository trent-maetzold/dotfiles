{
  config,
  lib,
  pkgs,
  ...
}: {
  home.preferXdgDirectories = true;
  # Shell-agnostic aliases (Home Manager writes them for every enabled shell).
  home.shellAliases = {
    wtf = "wtfutil";
    dot = "nvim ${config.home.homeDirectory}/.config/dotfiles";
    l = "eza -lah --git"; # oh-my-zsh's l
    # eza and bat aliases from nu_scripts (ryan4yin's setup)
    x = "eza --icons";
    xa = "eza --icons --all";
    xl = "eza --long";
    xla = "eza --long --all";
    xt = "eza --icons --tree";
    xta = "eza --icons --tree --all";
    b = "bat";
    bn = "bat --number";
    bp = "bat --plain";
  };
  home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];

  home.sessionVariables = {
    DO_NOT_TRACK = "1";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_DIR = "/etc/ssl/certs";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    GIT_SSL_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
  };

  systemd.user.startServices = "sd-switch";

  # Search and navigation
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    options = ["--cmd cd"]; # cd learns frecent dirs; nushell's ls stays structured
  };
  programs.bat = {
    enable = true;
    config.pager = "less -FR";
  };
  programs.eza = {
    enable = true;
    enableNushellIntegration = false; # nushell's ls is better; eza aliases come from nu_scripts
    git = true;
    icons = "auto";
  };
  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
    settings.display = {
      compact = false;
      use_pager = true;
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
  # Native dependencies
  programs.gcc.enable = true;

  home.packages = with pkgs; [
    tree-sitter

    # Build toolchain for native dependencies
    gnumake
    pkg-config

    # General utilities (after github:ryan4yin/nix-config)
    curl
    xh # friendlier curl for APIs
    openssl # genpass, cert inspection
    aria2
    croc # send files between machines
    jq
    yq-go
    sad # find-and-replace with preview
    ast-grep
    unzip
    zip
    p7zip
    file
    tree
    lsof
    pv
    trash-cli
    fastfetch
    visidata # TUI for csv/xlsx/json/sqlite
    pgcli
    nvd # diff two system builds

    # Disk and network
    duf
    gdu
    mtr
    gping
    doggo # dig, readable
    dnsutils
    nmap
    socat
    tcpdump
    iperf3
    just # programs.just is deprecated upstream

    # Docs lookup for agents
    ctx7 # Context7: current library docs
    deepwiki-cli # DeepWiki docs for public GitHub repos
  ];
}
