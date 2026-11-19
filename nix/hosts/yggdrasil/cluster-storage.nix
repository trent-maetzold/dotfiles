{pkgs, ...}: {
  boot.supportedFilesystems = ["nfs"];
  systemd.services.k3s = {
    path = [pkgs.nfs-utils];
    unitConfig.RequiresMountsFor = "/var/lib/rancher/k3s/storage";
  };

  services.k3s.manifests.nas-data.content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata.name = "media";
    }
    {
      apiVersion = "v1";
      kind = "PersistentVolume";
      metadata.name = "nas-data";
      spec = {
        capacity.storage = "1Gi"; # Static binding metadata, not a quota on Mimir.
        accessModes = ["ReadWriteMany"];
        persistentVolumeReclaimPolicy = "Retain";
        storageClassName = "";
        claimRef = {
          namespace = "media";
          name = "nas-data";
        };
        nfs = {
          server = "100.64.0.3"; # Mimir's tailnet address, reachable from Yggdrasil.
          path = "/mnt/user/data";
        };
      };
    }
    {
      apiVersion = "v1";
      kind = "PersistentVolumeClaim";
      metadata = {
        name = "nas-data";
        namespace = "media";
      };
      spec = {
        accessModes = ["ReadWriteMany"];
        resources.requests.storage = "1Gi";
        storageClassName = "";
        volumeName = "nas-data";
      };
    }
  ];
}
