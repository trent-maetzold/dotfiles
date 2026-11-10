{
  config,
  pkgs,
  ...
}: {
  programs.uv = {
    enable = true;
    # gssapi's setup.py looks for gssapi_ext.h under `krb5-config --prefix`, which
    # is krb5's lib output on Nix; without this its source build fails. uv passes
    # it only to gssapi's build.
    # Nix's python ignores nix-ld, so wheels needing libstdc++ etc. fail in it;
    # uv's own CPython builds load them through nix-ld.
    settings.python-preference = "only-managed";
    settings.extra-build-variables.gssapi.GSSAPI_COMPILER_ARGS = "-I${pkgs.krb5.dev}/include -DHAS_GSSAPI_EXT_H";
  };
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
