{
  lib,
  config,
  pkgs,
  llm-agents,
  ...
}: {
  programs.claude-code = {
    enable = true;
    package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
  };

  # Mounted into the magpie container (ai/magpie.nix) so it finds this agent's sign-in.
  virtualisation.quadlet.containers.magpie.containerConfig.volumes = ["${config.home.homeDirectory}/.claude:/config/home/.claude"];
  home.activation.claudecodeDir = lib.hm.dag.entryBefore ["writeBoundary"] "mkdir -p ~/.claude";
}
