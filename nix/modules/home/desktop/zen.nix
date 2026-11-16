# Zen with Tridactyl (vim keys), Bitwarden and Dark Reader. Pages follow the system's
# light/dark theme (Zen's default); Dark Reader skips sites that are already
# dark (its detectDarkTheme, on by default).
{
  config,
  pkgs,
  zen-browser,
  ...
}: {
  imports = [zen-browser.homeModules.beta];

  # Take over the profile selector Zen created before it was managed.
  home.file."${config.programs.zen-browser.configPath}/profiles.ini".force = true;

  # Tridactyl's rc (read at startup through its native helper). `s` opens
  # Zen's floating sidebar: Tridactyl can't reach Zen's interface, so it
  # presses Zen's own shortcut (Ctrl+Alt+S) with wtype.
  xdg.configFile."tridactyl/tridactylrc".text = ''
    bind s exclaim_quiet ${pkgs.wtype}/bin/wtype -M ctrl -M alt s -m alt -m ctrl
  '';

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [pkgs.tridactyl-native];
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
      settings = {
        # Ctrl+Tab cycles tabs by recency.
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        # Alt+letter is Zen's layer below, so the hidden menu bar's
        # Alt+letter access keys are off.
        "ui.key.menuAccessKey" = 0;
      };
      # Zen's own actions on Alt, with vim letters: sidebar, compact mode,
      # workspaces (h/l), split views.
      keyboardShortcuts = let
        alt = id: key: {
          inherit id key;
          modifiers.alt = true;
        };
        altShift = id: key: {
          inherit id key;
          modifiers = {
            alt = true;
            shift = true;
          };
        };
        off = id: {
          inherit id;
          disabled = true;
        };
      in
        [
          (alt "zen-toggle-sidebar" "s")
          (alt "zen-compact-mode-toggle" "c")
          (alt "zen-workspace-backward" "h")
          (alt "zen-workspace-forward" "l")
          (alt "zen-split-view-vertical" "v")
          (altShift "zen-split-view-horizontal" "v")
          (alt "zen-split-view-grid" "g")
          (alt "zen-split-view-unsplit" "q")
          # Zen moved the inspector to Ctrl+Shift+L; Firefox's Ctrl+Shift+C
          # is free again (copy URL below), and Bitwarden fills a login with
          # its own Ctrl+Shift+L.
          {
            id = "key_inspector";
            key = "c";
            modifiers = {
              accel = true;
              shift = true;
            };
          }
        ]
        # Tridactyl's defaults replace these: the same keys (find Ctrl+F,
        # bookmarks sidebar Ctrl+B, bookmark Ctrl+D, search Ctrl+E, glance
        # and open file Ctrl+O, page info Ctrl+I, view source Ctrl+U) or the
        # same actions (mute Alt+M, pin Alt+P, copy URL yy).
        ++ map off [
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
          "zen-copy-url"
        ];
    };
  };
}
