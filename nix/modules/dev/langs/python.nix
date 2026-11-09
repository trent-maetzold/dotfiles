{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ python3 uv ruff ty ];

  home.sessionVariables = {
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python/pycache";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
    RUFF_CACHE_DIR = "${config.xdg.cacheHome}/ruff";
  };

}
