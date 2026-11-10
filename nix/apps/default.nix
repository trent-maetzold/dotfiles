# Flake apps: tasks for administering NixOS/Home Manager deployments, so a host
# flake can re-export them (apps = dotfiles.apps); the justfiles wrap each one.
# One folder per app; its default.nix takes {pkgs, app} and returns `app ...`.
pkgs: let
  app = description: program: {
    type = "app";
    program = "${program}";
    meta = {inherit description;};
  };
in
  builtins.mapAttrs (name: _: import ./${name} {inherit pkgs app;})
  (pkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.))
