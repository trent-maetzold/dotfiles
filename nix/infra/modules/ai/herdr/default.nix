# herdr, a terminal workspace for running coding agents side by side.
{config, ...}: let
  modules.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    programs.herdr = {
      enable = true;

      package = lib.mkDefault pkgs.herdr-lld;

      settings = {
        onboarding = false;

        ui = {
          sidebar_width = 32;
          agent_panel_sort = "priority";
          status_indicators = "symbols";
          show_agent_labels_on_pane_borders = true;
          toast.delivery = "herdr";
          sound.enabled = true;
        };
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.herdr = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.herdr];
}
