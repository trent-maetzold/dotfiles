{pkgs, ...}: {
  boot.supportedFilesystems = ["nfs"];
  systemd.services.k3s = {
    path = [pkgs.nfs-utils];
    unitConfig.RequiresMountsFor = "/var/lib/rancher/k3s/storage";
  };
}
