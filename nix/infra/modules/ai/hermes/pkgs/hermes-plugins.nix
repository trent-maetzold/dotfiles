# Hermes directory plugins: plugin.yaml must sit at the package root.
{
  hermex-push,
  honcho,
  oh-my-hermes,
  ...
}: {
  flake.overlays.hermes-plugins = final: _: let
    makeHermesPlugin = name: src: final.runCommand name {} "cp -r ${src} $out";
  in {
    hermex-push-plugin = makeHermesPlugin "hermex-push" "${hermex-push}/plugin";
    honcho-plugin = makeHermesPlugin "honcho" "${honcho}/hermes-plugin-honcho";
    omh = makeHermesPlugin "omh" "${oh-my-hermes}/src/plugin_bundle/omh";
  };
}
