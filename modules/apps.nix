{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    upstream = inputs.zoldt-pkgs.apps.${system};
  in {
    packages = inputs.zoldt-pkgs.packages.${system};
    apps = {
      inherit (upstream) switch import-win-ca;
      bootstrap =
        upstream.bootstrap
        // {
          program = pkgs.lib.getExe (pkgs.writeShellApplication {
            name = "bootstrap";
            text = ''exec ${upstream.bootstrap.program} --flake ${pkgs.lib.escapeShellArg "${inputs.self}"} "$@"'';
          });
        };
    };
  };
}
