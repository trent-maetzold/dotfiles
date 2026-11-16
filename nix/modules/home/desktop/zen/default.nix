# Zen with Tridactyl (vim keys), Bitwarden and Dark Reader. Pages follow the
# system's light/dark theme (Zen's default); Dark Reader skips sites that are
# already dark (its detectDarkTheme, on by default).
#
# Keys: Tridactyl's defaults, plus a `,` menu for Zen's own interface. Each
# `,<letter>` is bound in Zen as Hyper+<letter> (Super+Ctrl+Alt+Shift; Niri
# binds none of these), which Tridactyl presses with wtype through its native
# helper. Every other Zen and Firefox shortcut is unbound except zoom, F12,
# private window and clear history; text editing keys (copy, paste, ...) stay.
# Bitwarden fills logins with its own Ctrl+Shift+L.
{
  config,
  lib,
  pkgs,
  zen-browser,
  ...
}: let
  # Home and new tabs: DuckDuckGo until the homepage dashboard is up.
  home = "https://duckduckgo.com";

  # `,<letter>` in Tridactyl -> Zen/Firefox shortcut id.
  zenActions = {
    s = "zen-compact-mode-show-sidebar"; # floating sidebar
    c = "zen-compact-mode-toggle";
    l = "zen-library-toggle"; # Zen's Library panel
    j = "zen-workspace-forward";
    k = "zen-workspace-backward";
    v = "zen-split-view-vertical";
    x = "zen-split-view-horizontal";
    q = "zen-split-view-unsplit";
    d = "key_openDownloads";
    h = "showAllHistoryKb"; # Library: history
    b = "manBookmarkKb"; # Library: bookmarks
    a = "key_openAddons";
  };
  hyper = key: "${pkgs.wtype}/bin/wtype -M logo -M ctrl -M alt -M shift ${key} -m shift -m alt -m ctrl -m logo";

  # Firefox shortcuts kept at their defaults.
  kept = [
    "key_fullZoomEnlarge"
    "key_fullZoomReduce"
    "key_fullZoomReset"
    "key_toggleToolboxF12"
    "key_privatebrowsing"
    "key_sanitize"
  ];
  unbound = lib.subtractLists (kept ++ lib.attrValues zenActions) (import ./_shortcut-ids.nix);
in {
  imports = [zen-browser.homeModules.beta];

  # Take over the profile selector Zen created before it was managed.
  home.file."${config.programs.zen-browser.configPath}/profiles.ini".force = true;

  # Read at startup through Tridactyl's native helper.
  xdg.configFile."tridactyl/tridactylrc".text = lib.concatLines (
    [
      # Show pending keys (e.g. `,`) in the mode indicator.
      "set modeindicatorshowkeys true"
      # about: pages open through the native helper, as `zen-beta <url>`.
      "set browser zen-beta"
      # Firefox has no new-tab URL setting; Tridactyl owns the new-tab page.
      "set newtab ${home}"
      "bind ,p tabopen about:preferences"
    ]
    ++ lib.mapAttrsToList (key: _: "bind ,${key} exclaim_quiet ${hyper key}") zenActions
  );

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
        # Home button and Tridactyl's gh.
        "browser.startup.homepage" = home;
      };
      keyboardShortcuts =
        lib.mapAttrsToList (key: id: {
          inherit id key;
          modifiers = {
            meta = true;
            accel = true;
            alt = true;
            shift = true;
          };
        })
        zenActions
        ++ map (id: {
          inherit id;
          disabled = true;
        })
        unbound;
    };
  };
}
