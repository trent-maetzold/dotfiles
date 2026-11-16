# Zen with Vimium C, Bitwarden and Dark Reader. Pages follow the system's
# light/dark theme (Zen's default); Dark Reader skips sites that are already
# dark (its detectDarkTheme, on by default).
{
  config,
  zen-browser,
  ...
}: {
  imports = [zen-browser.homeModules.beta];

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
      # Ctrl+Tab cycles tabs by recency.
      settings."browser.ctrlTab.sortByRecentlyUsed" = true;
    };
  };
}
