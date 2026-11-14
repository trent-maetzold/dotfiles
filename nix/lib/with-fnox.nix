# Wrap every binary of `package` to run under `fnox exec`, so the named secrets
# from that fnox.toml reach only that process, e.g.
#   pkgs.withFnox "/home/me/.config/nixos/fnox.toml" ["BKT_TOKEN"] pkgs.bkt
pkgs: config: secrets: package:
pkgs.symlinkJoin {
  name = "${package.name}-with-fnox";
  paths = [package];
  postBuild = ''
    for bin in $out/bin/*; do
      target=$(readlink -f "$bin")
      rm "$bin"
      printf '#!${pkgs.runtimeShell}\nexec ${pkgs.lib.getExe pkgs.fnox} -c %q exec --only %q -- %q "$@"\n' \
        ${pkgs.lib.escapeShellArg config} ${pkgs.lib.escapeShellArg (pkgs.lib.concatStringsSep "," secrets)} "$target" > "$bin"
      chmod +x "$bin"
    done
  '';
  inherit (package) meta;
}
