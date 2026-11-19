{
  services.k3s.manifests.traefik-config.content = {
    apiVersion = "helm.cattle.io/v1";
    kind = "HelmChartConfig";
    metadata = {
      name = "traefik";
      namespace = "kube-system";
    };
    spec.valuesContent = builtins.toJSON {
      service.spec = {
        allocateLoadBalancerNodePorts = false;
        loadBalancerSourceRanges = ["100.64.0.6/32"];
      };
      ingressClass.isDefaultClass = false;
      providers = {
        kubernetesCRD.enabled = false;
        kubernetesIngress = {
          ingressClass = "traefik";
          publishedService.enabled = false;
        };
      };
      ports.web.expose.default = false;
    };
  };
}
