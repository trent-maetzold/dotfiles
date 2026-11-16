# Zen with Tridactyl (vim keys), Bitwarden and Dark Reader. Pages follow the system's
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
      "tridactyl.vim@cmcaine.co.uk" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim/latest.xpi";
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
      # Unbind Zen and Firefox shortcuts that Tridactyl's defaults replace
      # (same keys, or the same action): find (Ctrl+F, Tridactyl /), the
      # bookmarks sidebar (Ctrl+B), bookmark page (Ctrl+D), search (Ctrl+E),
      # glance and open file (Ctrl+O), page info (Ctrl+I), view source
      # (Ctrl+U), mute (Ctrl+M, Tridactyl Alt+M) and pin (Ctrl+Shift+D,
      # Tridactyl Alt+P). Ctrl+Alt+S shows or hides the sidebar.
      # Bitwarden fills a login with its own Ctrl+Shift+L.
      keyboardShortcuts =
        map (id: {
          inherit id;
          disabled = true;
        }) [
          "key_find"
          "viewBookmarksSidebarKb"
          "addBookmarkAsKb"
          "key_search2"
          "zen-glance-expand"
          "openFileKb"
          "key_viewInfo"
          "key_viewSource"
          "key_toggleMute"
          "zen-toggle-pin-tab"
          "zen-compact-mode-show-sidebar"
        ]
        ++ [
          {
            id = "zen-toggle-sidebar";
            key = "s";
            modifiers = {
              accel = true;
              alt = true;
            };
          }
        ];
    };
  };
}
