{
  pkgs,
  llm-agents,
  ...
}: {
  programs.codex = {
    enable = true;
    package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  };
}
