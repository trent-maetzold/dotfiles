{inputs, ...}: {
  perSystem = {system, ...}: let
    pkgs = inputs.nixpkgs.legacyPackages.${system}.extend inputs.self.overlays.default;
    app = description: program: {
      type = "app";
      program = "${program}";
      meta = {inherit description;};
    };
  in {
    apps.import-win-ca = ( # The Windows half (windows-cas.py) runs under uv.exe, so the whole folder goes
      # to the store to keep it beside the script. wslpath and uv.exe come from
      # WSL/Windows, not Nix, so they can't be runtimeInputs.
      {
        pkgs,
        app,
      }:
        app "Export the Windows CAs (WSL) to a PEM bundle" (pkgs.lib.getExe (pkgs.writeShellApplication {
          name = "import-win-ca";
          runtimeInputs = [pkgs.uv];
          text = ''exec ${./.}/import-win-ca.py "$@"'';
        }))
    ) {inherit pkgs app;};
  };
}
