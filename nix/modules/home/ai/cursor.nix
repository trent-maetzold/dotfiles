# Cursor's agent CLI (cursor-agent), not the editor.
{
  lib,
  config,
  pkgs,
  llm-agents,
  ...
}: {
  home.packages = [llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cursor-agent];

  # Mounted into the magpie container (ai/magpie.nix) so it finds this agent's sign-in.
  virtualisation.quadlet.containers.magpie.containerConfig.volumes = ["${config.home.homeDirectory}/.cursor:/config/home/.cursor" "${config.home.homeDirectory}/.config/cursor:/config/home/.config/cursor"];
  home.activation.cursorDir = lib.hm.dag.entryBefore ["writeBoundary"] "mkdir -p ~/.cursor ~/.config/cursor";
}
