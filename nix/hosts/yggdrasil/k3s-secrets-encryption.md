# k3s Secret encryption on Nidavellir

Yggdrasil's k3s server starts with `--secrets-encryption` in `default.nix`.
The former unencrypted cluster was discarded and the server initialized a
fresh datastore with encryption enabled. Do not repeat a reset as a routine
upgrade: deleting cluster state or persistent volumes destroys data.

Check the configuration and workload health without printing secrets:

```sh
sudo k3s secrets-encrypt status
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A
sudo k3s kubectl -n flux-system get gitrepository,kustomization,fluxinstance
```

A fresh encrypted cluster can report `Enabled`, an active AES-CBC key and
rotation stage `start`; this is normal and does not require a key rotation.
Follow the version-matched [k3s secrets encryption documentation](https://docs.k3s.io/cli/secrets-encrypt)
when rotating keys or migrating a different, existing unencrypted cluster.

For recovery, protect and retain the datastore snapshots, k3s server token,
and encryption configuration and keys outside the host; validate restoration.
The local-path storage dataset and Mimir's NFS share have separate backup
requirements. Encryption at rest does not prevent Kubernetes API users with
sufficient permission from reading Secrets.
