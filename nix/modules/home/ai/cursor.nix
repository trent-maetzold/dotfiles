# Cursor's agent CLI (cursor-agent), not the editor.
{
  pkgs,
  llm-agents,
  ...
}: {
  home.packages = [llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cursor-agent];
}
