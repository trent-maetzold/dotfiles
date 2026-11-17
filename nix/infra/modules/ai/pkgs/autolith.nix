# autolith from its flake: llm-agents' predates ACP.
{autolith, ...}: {
  flake.overlays.autolith = final: _: {autolith = autolith.packages.${final.stdenv.hostPlatform.system}.default;};
}
