# Enable k3s Secret encryption on Nidavellir

Yggdrasil was created without Secret encryption. The `--secrets-encryption`
flag in `default.nix` is only one part of the existing-cluster migration; do
not switch to it before preparing k3s. This procedure causes k3s downtime.
It is for the current single-server cluster only.

Before starting, confirm a restorable, protected etcd snapshot and the k3s
server token are available outside Yggdrasil. Protect the encryption config and
keys too; they are needed to recover encrypted data. Verify the exact procedure
against the installed k3s version and plan recovery before continuing.

1. Check `sudo k3s secrets-encrypt status` reports disabled and confirm the
   cluster has a single server.
2. Run `sudo k3s secrets-encrypt enable` on Yggdrasil.
3. Switch to the NixOS configuration with `--secrets-encryption`, restarting
   k3s, and check that the status is disabled at rotation stage `start`.
4. Run `sudo k3s secrets-encrypt rotate-keys`, restart k3s as directed by the
   installed version's documentation, and wait for the status to report
   `Enabled` and `reencrypt_finished`.
5. Verify the API, Flux, and existing applications. Confirm existing Secrets
   were re-encrypted and exercise recovery with the encrypted datastore and
   its required keys before relying on the configuration.

Do not print Kubernetes Secret values or encryption keys during verification.
Use the version-matched [k3s secrets encryption documentation](https://docs.k3s.io/cli/secrets-encrypt)
for the full procedure and any changes to the sequence.
