{
  lib,
  config,
  pkgs,
  llm-agents,
  ...
}: {
  programs.codex = {
    enable = true;
    # Codex writes its own settings (trusted projects, model picks); merge ours in.
    mutableSettings = true;
    package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  };

  # Mounted into the magpie container (ai/magpie.nix) so it finds this agent's sign-in.
  virtualisation.quadlet.containers.magpie.containerConfig.volumes = ["${config.home.homeDirectory}/.codex:/config/home/.codex"];
  home.activation.codexDir = lib.hm.dag.entryBefore ["writeBoundary"] "mkdir -p ~/.codex";
}
