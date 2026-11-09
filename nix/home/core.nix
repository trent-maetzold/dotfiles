{
  # Where this repo is checked out. Out-of-store symlinks point into it, so
  # edits to config/* take effect without a rebuild.
  flake.homeModules.core = {
    config,
    lib,
    ...
  }: {
    options.dotfiles.path = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Work/configs/dotfiles";
      description = "Absolute path of the dotfiles checkout.";
    };

    config.programs.home-manager.enable = true;
  };
}
