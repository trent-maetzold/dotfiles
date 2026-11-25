{
  flake.modules.homeManager.shell-btop = {
    programs.btop = {
      enable = true;
      settings.vim_keys = true;
    };
  };
}
