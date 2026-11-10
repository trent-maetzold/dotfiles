# sops-nix: the host sets sops.defaultSopsFile and declares sops.secrets; each
# decrypts to a file only you can read. Fill secrets.yaml from Keeper/rbw with
# the sync-secrets app.
{
  config,
  pkgs,
  sops-nix,
  ...
}: {
  imports = [sops-nix.homeManagerModules.sops];
  home.packages = [pkgs.sops];
  sops.age.keyFile = "${config.xdg.configHome}/age/keys.txt";
}
