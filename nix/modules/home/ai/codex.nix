{
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
}
