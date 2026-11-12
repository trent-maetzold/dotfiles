# DeepSeek Harness (dsh; `dsh web` serves its UI) and Codewhale, the separate
# DeepSeek terminal agent formerly called DeepSeek-TUI (not a dsh plugin).
{
  pkgs,
  llm-agents,
  ...
}: {
  home.packages = [
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh
    pkgs.codewhale
  ];
}
