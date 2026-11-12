# Kubernetes client tools, after github:ryan4yin/nix-config (home/base/tui/container.nix).
{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl
    kustomize
    kubeconform # manifest validation
    kubectx # kubectx/kubens
    kubie # per-shell contexts
    kubectl-view-secret
    kubectl-node-shell
    kubepug # deprecated-API checker
    kubernetes-helm
    fluxcd
    dive # image layer explorer
    skopeo # inspect/copy images without pulling
  ];

  programs.k9s.enable = true;
  programs.kubecolor = {
    enable = true;
    enableAlias = true; # kubectl -> kubecolor
  };
  home.shellAliases.k = "kubecolor";
}
