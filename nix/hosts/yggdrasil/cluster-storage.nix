{pkgs, ...}: {
  boot.supportedFilesystems = ["nfs"];
  systemd.services.k3s = {
    path = [pkgs.nfs-utils];
    unitConfig.RequiresMountsFor = "/var/lib/k3s-volumes";
  };

  services.k3s = {
    extraFlags = ["--default-local-storage-path=/var/lib/k3s-volumes"];
    manifests.mimir-media.content = [
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "media";
      }
      {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata.name = "mimir-media";
        spec = {
          capacity.storage = "1Gi"; # Static binding metadata, not a quota on Mimir.
          accessModes = ["ReadWriteMany"];
          persistentVolumeReclaimPolicy = "Retain";
          storageClassName = "";
          claimRef = {
            namespace = "media";
            name = "mimir-media";
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
          name = "mimir-media";
          namespace = "media";
        };
        spec = {
          accessModes = ["ReadWriteMany"];
          resources.requests.storage = "1Gi";
          storageClassName = "";
          volumeName = "mimir-media";
        };
      }
    ];
  };
}
