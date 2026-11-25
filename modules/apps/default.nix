# Flake apps: tasks for administering NixOS/Home Manager deployments, so a host
# flake can re-export them (apps = dotfiles.apps); the justfiles wrap each.
# One folder per app; its default.nix takes any of {pkgs, app, self} and
# returns `app ...`.
{
  pkgs,
  self,
}: let
  app = description: program: {
    type = "app";
    program = "${program}";
    meta = {inherit description;};
  };

  callApp = name: let
    makeApp = import ./${name};
  in
    makeApp (builtins.intersectAttrs (builtins.functionArgs makeApp) {inherit pkgs app self;});
in
  builtins.mapAttrs (name: _: callApp name)
  (pkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.))
