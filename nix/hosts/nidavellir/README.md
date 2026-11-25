# Niðavellir

Fresh K3s in a QEMU MicroVM declared in Yggdrasil’s NixOS configuration. Yggdrasil’s existing K3s stays separate. The guest does not import its workloads or GitOps bootstrap and needs no bridge or host firewall changes.

## Start on Yggdrasil

After the PR merges, check `comin status` on Yggdrasil and wait for the merged `main` revision to be staged. Yggdrasil uses Comin’s `boot` operation, so reboot during a maintenance window to boot the staged generation. The VM starts automatically. Verify on Yggdrasil:

```bash
sudo systemctl status microvm@nidavellir.service
sudo journalctl -u microvm@nidavellir.service -f
```

The persistent `/var` disk lives at `/var/lib/microvms/nidavellir/nidavellir-state.img` on Yggdrasil. It holds the K3s datastore and local volumes, Tailscale identity, and SSH host key. Host switches do not automatically restart the VM; explicitly restart `microvm@nidavellir.service` to boot updated guest configuration.

## Enroll and verify

```bash
rbw unlock  # if using Muninn’s Bitwarden SSH agent
ssh -J trent@yggdrasil.ts.trkm.io -p 2228 trent@127.0.0.1
```

Inside the guest:

```bash
sudo tailscale up --login-server=https://hs.trkm.io --hostname=nidavellir --netfilter-mode=off
sudo systemctl status k3s
sudo k3s kubectl get nodes -o wide
sudo k3s secrets-encrypt status
```

Follow the Headscale enrollment URL from `tailscale up`. K3s waits for the guest’s tailnet IPv4 before initializing. Use an appropriate Headscale policy for API access: allow administrators and joining nodes, not general app clients. Verify that the guest resolves as `nidavellir.ts.trkm.io` before using that address from clients.

To use the admin kubeconfig on Muninn, run from Bash after the node is ready:

```bash
(
  set -e
  umask 077
  mkdir -p ~/.kube
  set -o noclobber
  ssh -J trent@yggdrasil.ts.trkm.io -p 2228 trent@127.0.0.1 'sudo -n cat /etc/rancher/k3s/k3s.yaml' \
    > ~/.kube/nidavellir-microvm.yaml
  kubectl --kubeconfig ~/.kube/nidavellir-microvm.yaml config set-cluster default \
    --server=https://nidavellir.ts.trkm.io:6443
)
kubectl --kubeconfig ~/.kube/nidavellir-microvm.yaml get nodes
```

This kubeconfig grants full admin. Never commit it. If the copy fails, check for an empty or partial file before retrying.

## Cluster choices and ports

- Single embedded-etcd server, schedulable; one server is not HA. Enable encryption at rest for Kubernetes Secret resources from the first start (`secretbox`). This does not encrypt all etcd data or workload volumes; keep etcd snapshots and the matching server token in secure off-VM backups.
- IPv4-only pods `10.62.0.0/16`, Services `10.63.0.0/16`, cluster DNS `10.63.0.10`. Keep these consistent on additional servers and avoid advertising overlapping routes. CoreDNS, local-path storage, and metrics-server are left at K3s defaults. Local-path volumes are not replicated.
- Start with TCP **6443** on `tailscale0`. SSH is forwarded only through Yggdrasil’s loopback. Traefik and ServiceLB are disabled; open **80/443** only when you install ingress, on the actual ingress entry point.
- Before adding workers, permit **UDP 8472** for Flannel VXLAN between cluster nodes on the tailnet, and **TCP 10250** between nodes if using metrics-server. Configure those nodes with their own tailnet IP and `--flannel-iface=tailscale0`. Verify cross-node pod traffic and MTU with a second node; no multi-node path has been tested yet. Never expose VXLAN publicly.
- For embedded-etcd HA, prefer three servers and allow **TCP 2379–2380** only among those servers. Don’t open them for workers or clients. No NodePort range is needed for this setup.
