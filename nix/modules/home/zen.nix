{
  config,
  zen-browser,
  ...
}: {
  imports = [zen-browser.homeModules.beta];

  # Replace the initial unmanaged selector; leave its old profile data alone.
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
    };
    profiles.default = {
      name = "default";
      isDefault = true;
      settings."browser.ctrlTab.sortByRecentlyUsed" = false;
    };
  };
}
