# sops-nix for system services, with the `user`'s age key; the host sets
# sops.defaultSopsFile and declares sops.secrets.
{
  sops-nix,
  user,
  ...
}: {
  imports = [sops-nix.nixosModules.sops];
  sops.age.keyFile = "${user.home}/.config/age/keys.txt";
}
