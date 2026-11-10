{
  config,
  pkgs,
  ...
}: {
  programs.uv.enable = true;
  programs.ty.enable = true;
  programs.ruff = {
    enable = true;
    settings.cache-dir = "${config.xdg.cacheHome}/ruff";
  };

  home.packages = [pkgs.python3];

  home.sessionVariables = {
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python/pycache";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
  };
}
