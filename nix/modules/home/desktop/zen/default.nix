# Zen with Vimium C (vim keys, its defaults), Bitwarden and Dark Reader. Pages
# follow the system's light/dark theme (Zen's default); Dark Reader skips
# sites that are already dark (its detectDarkTheme, on by default).
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

  # Take over the profile selector Zen created before it was managed.
  home.file."${config.programs.zen-browser.configPath}/profiles.ini".force = true;

  programs.zen-browser = {
    enable = true;
    policies.ExtensionSettings = {
      "vimium-c@gdh1995.cn" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
      };
      # Tried instead of Vimium C; blocked so Zen removes the old install.
      "tridactyl.vim@cmcaine.co.uk".installation_mode = "blocked";
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
