{
  imports = [../../../../modules/nixos/partitions/ext4-efi.nix];

  virtualisation.diskSize = 24 * 1024;
}
