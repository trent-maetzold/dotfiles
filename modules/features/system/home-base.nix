{
  flake.modules.homeManager.default = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.preferXdgDirectories = true;
    # Shell-agnostic aliases (Home Manager writes them for every enabled shell).
    home.shellAliases = {
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

    # Command-line tools, many after github:ryan4yin/nix-config.

    # Files: search, navigation, viewing
    programs.ripgrep.enable = true;
    programs.fd.enable = true;
    programs.fzf.enable = true;
    programs.zoxide = {
      enable = true;
      options = ["--cmd cd"]; # cd learns frecent dirs; nushell's ls stays structured
    };
    programs.eza = {
      enable = true;
      enableNushellIntegration = false; # nushell's ls is better; eza aliases come from nu_scripts
      git = true;
      icons = "auto";
    };
    programs.bat = {
      enable = true;
      config.pager = "less -FR";
    };

    # Help pages
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = true;
      settings.display = {
        compact = false;
        use_pager = true;
      };
    };

    # Git diffs
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    # Build toolchain for native dependencies
    programs.gcc.enable = true;

    # Encryption and signing
    programs.gpg.enable = true;

    # Media downloads
    programs.yt-dlp.enable = true;

    home.packages = with pkgs; [
      headscale-remote
      # Build toolchain for native dependencies
      gnumake
      pkg-config
      tree-sitter
      just # programs.just is deprecated upstream

      # Files and archives
      file
      tree
      trash-cli
      sad # find-and-replace with preview
      ast-grep # structural search and replace
      pv
      unzip
      zip
      p7zip

      # Media
      ffmpeg

      # Diagrams and documents
      mermaid-cli
      ghostscript # gs
      tectonic

      # Data
      jq
      yq-go
      visidata # TUI for csv/xlsx/json/sqlite
      pgcli

      # HTTP and file transfer
      curl
      wget
      xh # friendlier curl for APIs
      aria2
      croc # send files between machines

      # Disk
      duf
      gdu

      # Network
      mtr
      gping
      doggo # dig, readable
      dnsutils
      nmap
      socat
      tcpdump
      iperf3

      # System
      lsof
      fastfetch

      # Docs lookup for agents
      ctx7 # Context7: current library docs
      deepwiki-cli # DeepWiki docs for public GitHub repos
    ];
  };
}
