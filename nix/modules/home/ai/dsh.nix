# DeepSeek Harness (dsh) and dsh-TUI. dsh-TUI is a dsh plugin installed with pnpm
# into the mutable dsh-tui profile (~/.dsh/profiles/dsh-tui); `dsh-tui` adds it
# on first launch, and its own /update keeps it current.
{
  lib,
  config,
  pkgs,
  llm-agents,
  ...
}: let
  dsh = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh;
  dsh-tui = pkgs.writeShellApplication {
    name = "dsh-tui";
    runtimeInputs = [dsh pkgs.pnpm pkgs.nodejs];
    text = ''
      plugin=@deepseek-harness-tui/dsh-tui
      if [ ! -d "''${DSH_HOME:-$HOME/.dsh}/profiles/dsh-tui/node_modules/$plugin" ]; then
        dsh plugin --profile dsh-tui add "$plugin"
      fi
      exec dsh --profile dsh-tui "$@"
    '';
  };
in {
  home.packages = [dsh dsh-tui];

  # Mounted into the magpie container (ai/magpie.nix) so it finds this agent's sign-in.
  virtualisation.quadlet.containers.magpie.containerConfig.volumes = ["${config.home.homeDirectory}/.dsh:/config/home/.dsh"];
  home.activation.dshDir = lib.hm.dag.entryBefore ["writeBoundary"] "mkdir -p ~/.dsh";
}
