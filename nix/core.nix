{
  config,
  vars,
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
      default = "${config.home.homeDirectory}/Work/configs/dotfiles";
      description = "Absolute path of the dotfiles checkout.";
    };

    config.home.stateVersion = lib.mkDefault vars.stateVersion;
  };

  flake.modules.homeManager.default.imports = [hm.core];
}
