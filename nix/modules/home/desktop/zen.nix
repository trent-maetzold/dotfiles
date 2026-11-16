# Zen with Vimium C, Bitwarden and Dark Reader (default settings), on graphical
# desktops. Sites are asked for their dark theme; Dark Reader darkens only those
# without one (its detectDarkTheme, on by default).
{
  config,
  lib,
  osConfig ? {},
  zen-browser,
  ...
}: {
  imports = [zen-browser.homeModules.beta];

  config = lib.mkIf (osConfig.services.graphical-desktop.enable or false) {
    # Take over the profile selector Zen created before it was managed.
    home.file."${config.programs.zen-browser.configPath}/profiles.ini".force = true;

    programs.zen-browser = {
      enable = true;
      policies.ExtensionSettings = {
        "vimium-c@gdh1995.cn" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
      };
      profiles.default = {
        name = "default";
        isDefault = true;
        settings = {
          # Ctrl+Tab cycles tabs by recency.
          "browser.ctrlTab.sortByRecentlyUsed" = true;
          # Ask every site for its dark theme (prefers-color-scheme: dark).
          "layout.css.prefers-color-scheme.content-override" = 0;
        };
      };
    };
  };
}
