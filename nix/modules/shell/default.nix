{config, ...}: {
  programs.starship.enable = true;

  home.shellAliases.dot = "nvim ${config.home.homeDirectory}/.config/dotfiles";
}
