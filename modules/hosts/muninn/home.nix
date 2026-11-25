{
  flake.modules.homeManager.muninn =
    # trent's Home Manager config on muninn: every dotfiles home module and the
    # desktop ones (Umbriel, Noctalia, Zen, ...).
    {...}: {
      programs.umbriel.settings.output."eDP-1".scale = 1.4;
    };
}
