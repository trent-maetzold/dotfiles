{
  services.k3s.manifests.traefik-config.content = {
    apiVersion = "helm.cattle.io/v1";
    kind = "HelmChartConfig";
    metadata = {
      name = "traefik";
      namespace = "kube-system";
    };
    spec.valuesContent = builtins.toJSON {
      hostNetwork = true;
      nodeSelector."kubernetes.io/hostname" = "yggdrasil";
      updateStrategy = {
        type = "Recreate";
        rollingUpdate = null;
      };
      service.enabled = false;
      ingressClass.isDefaultClass = false;
      providers = {
        kubernetesCRD.enabled = false;
        kubernetesIngress = {
          ingressClass = "traefik";
          publishedService.enabled = false;
        };
      };
      ports = {
        web = {
          hostIP = "100.64.0.2";
          port = 8000;
          forwardedHeaders.trustedIPs = ["100.64.0.6/32"];
        };
        websecure = null;
        traefik.hostIP = "127.0.0.1";
        metrics.hostIP = "127.0.0.1";
      };
    };
  };
}
