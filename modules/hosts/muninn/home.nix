# trent's Home Manager config on muninn: every dotfiles home module and the
# desktop ones (Umbriel, Noctalia, Zen, ...).
{...}: {
  imports = [
    ../../users/trent
  ];

  programs.umbriel.settings.output."eDP-1".scale = 1.4;
}
