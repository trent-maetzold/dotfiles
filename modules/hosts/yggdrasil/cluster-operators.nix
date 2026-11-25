{inputs, ...}: {
  # K3s needs these two files to bootstrap Flux before Git reconciliation exists.
  # Their definitions live in the homelab repository; all other cluster
  # resources are reconciled by Flux after the staged handoff.
  services.k3s.manifests = {
    flux-operator.source = "${inputs.homelab}/bootstrap/nidavellir/flux-operator.yaml";
    flux-instance.source = "${inputs.homelab}/bootstrap/nidavellir/flux-instance.yaml";
  };
}
