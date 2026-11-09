{
  config,
  stateVersion,
  ...
}: let
  hm = config.flake.modules.homeManager;
in {
  flake.modules.homeManager.core = {
    config,
    lib,
    ...
  }: {
    # Out-of-store symlinks point into this checkout, so edits to config/*
    # take effect without a rebuild. Containers mount from it too.
    options.dotfiles.path = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/dotfiles";
      description = "Absolute path of the dotfiles checkout.";
    };

    config.home.stateVersion = lib.mkDefault stateVersion;
  };

  flake.modules.homeManager.default.imports = [hm.core];
}
