# Zen with Vimium C (vim keys, its defaults), Bitwarden, Dark Reader and
# uBlock Origin, and no other extensions. Pages follow the system's
# light/dark theme (Zen's default); Dark Reader skips sites that are already
# dark (its detectDarkTheme, on by default).
#
# Keys: Zen's own actions that Vimium C has no key for are on
# Ctrl+Alt+<letter> (the floating sidebar on Ctrl+S). Every other Zen and Firefox shortcut is unbound except zoom, F12,
# private window and clear history; text editing keys (copy, paste, ...)
# stay. Bitwarden fills logins with its own Ctrl+Shift+L.
{
  config,
  lib,
  zen-browser,
  ...
}: let
  ctrlAlt = key: {
    inherit key;
    modifiers = {
      accel = true;
      alt = true;
    };
  };
  # Zen/Firefox shortcut id -> key, for what Vimium C can't do (it has
  # bookmarks on b/B, history in o/O, tabs on t/T/x/X/J/K, ...).
  bound = {
    zen-compact-mode-show-sidebar = {
      key = "s";
      modifiers.accel = true;
    }; # floating sidebar
    zen-compact-mode-toggle = ctrlAlt "s";
    zen-library-toggle = ctrlAlt "l"; # Zen's Library panel
    zen-workspace-forward = ctrlAlt "j";
    zen-workspace-backward = ctrlAlt "k";
    zen-split-view-vertical = ctrlAlt "v";
    zen-split-view-horizontal = ctrlAlt "x";
    zen-split-view-unsplit = ctrlAlt "q";
    key_openDownloads = ctrlAlt "d";
    key_openAddons = ctrlAlt "a";
  };
  # Firefox shortcuts kept at their defaults.
  kept = [
    "key_fullZoomEnlarge"
    "key_fullZoomReduce"
    "key_fullZoomReset"
    "key_toggleToolboxF12"
    "key_privatebrowsing"
    "key_sanitize"
  ];
  unbound = lib.subtractLists (kept ++ lib.attrNames bound) (import ./_shortcut-ids.nix);
in {
  imports = [zen-browser.homeModules.beta];

  # Zen opens as a maximized column (Niri's Mod+F), not fullscreen.
  wayland.windowManager.niri.settings._children = [
    {
      window-rule._children = [
        {match._props.app-id = "^zen-beta$";}
        {open-maximized = true;}
      ];
    }
  ];

  # Take over the profile selector Zen created before it was managed.
  home.file."${config.programs.zen-browser.configPath}/profiles.ini".force = true;

  programs.zen-browser = {
    enable = true;
    # Only these extensions: anything else is blocked, and Zen removes it.
    policies.ExtensionSettings = let
      amo = slug: {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      };
    in {
      "*".installation_mode = "blocked";
      "vimium-c@gdh1995.cn" = amo "vimium-c";
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = amo "bitwarden-password-manager";
      "addon@darkreader.org" = amo "darkreader";
      "uBlock0@raymondhill.net" = amo "ublock-origin";
    };
    profiles.default = {
      name = "default";
      isDefault = true;
      settings = {
        # Ctrl+Tab cycles tabs by recency.
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        # Home button: DuckDuckGo until the homepage dashboard is up. New tabs
        # open Zen's search bar.
        "browser.startup.homepage" = "https://duckduckgo.com";
      };
      keyboardShortcuts =
        lib.mapAttrsToList (id: k: k // {inherit id;}) bound
        ++ map (id: {
          inherit id;
          disabled = true;
        })
        unbound;
    };
  };
}
