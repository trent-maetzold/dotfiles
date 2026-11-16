# Zen with Tridactyl (vim keys), Bitwarden and Dark Reader. Pages follow the
# system's light/dark theme (Zen's default); Dark Reader skips sites that are
# already dark (its detectDarkTheme, on by default).
#
# Keys: Tridactyl's defaults, plus a `,` menu for Zen's own interface. Each
# menu entry gets a spare key no keyboard has (F13, F14, ...) bound in Zen;
# Tridactyl presses it with wtype through its native helper. Zen and Firefox
# shortcuts that Tridactyl's defaults replace are unbound.
{
  config,
  lib,
  pkgs,
  zen-browser,
  ...
}: let
  # Tridactyl key -> Zen/Firefox shortcut id, in F13.. order.
  zenActions = [
    [",s" "zen-compact-mode-show-sidebar"] # floating sidebar
    [",c" "zen-compact-mode-toggle"]
    [",l" "zen-library-toggle"] # Zen's Library panel
    [",j" "zen-workspace-forward"]
    [",k" "zen-workspace-backward"]
    [",v" "zen-split-view-vertical"]
    [",x" "zen-split-view-horizontal"]
    [",q" "zen-split-view-unsplit"]
    [",d" "key_openDownloads"]
    [",h" "showAllHistoryKb"] # Library: history
    [",b" "manBookmarkKb"] # Library: bookmarks
    [",a" "key_openAddons"]
  ];
  fkey = i: "F${toString (13 + i)}";
  actions =
    lib.imap0 (i: a: {
      bind = lib.elemAt a 0;
      id = lib.elemAt a 1;
      key = fkey i;
    })
    zenActions;

  # Same keys (find Ctrl+F, bookmarks sidebar Ctrl+B, bookmark Ctrl+D, search
  # Ctrl+E, glance and open file Ctrl+O, page info Ctrl+I, view source Ctrl+U)
  # or same actions (mute Alt+M, pin Alt+P, copy URL yy) as Tridactyl.
  replacedByTridactyl = [
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
      "bind ,p tabopen about:preferences"
    ]
    ++ map (a: "bind ${a.bind} exclaim_quiet ${pkgs.wtype}/bin/wtype -k ${a.key}") actions
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
      # Ctrl+Tab cycles tabs by recency.
      settings."browser.ctrlTab.sortByRecentlyUsed" = true;
      keyboardShortcuts =
        map (a: {
          inherit (a) id;
          keycode = "VK_${a.key}";
        })
        actions
        ++ map (id: {
          inherit id;
          disabled = true;
        })
        replacedByTridactyl
        ++ [
          # Zen moved the inspector to Ctrl+Shift+L; back to Firefox's
          # Ctrl+Shift+C (copy URL is Tridactyl's yy), so Bitwarden's
          # Ctrl+Shift+L fills logins.
          {
            id = "key_inspector";
            key = "c";
            modifiers = {
              accel = true;
              shift = true;
            };
          }
        ];
    };
  };
}
