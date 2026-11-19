{
  services.k3s.autoDeployCharts = {
    flux-operator = {
      repo = "oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator";
      version = "0.62.1";
      hash = "sha256-GTB1X1CTsljECKKLcCyXkJAoPgCLctQT9ukqSwl6uQg=";
      targetNamespace = "flux-system";
      createNamespace = true;
    };

    flux-instance = {
      repo = "oci://ghcr.io/controlplaneio-fluxcd/charts/flux-instance";
      version = "0.62.1";
      hash = "sha256-HPJFm7bIm/dgsZgWYasBDjI9mIM3o59myUhCOQZRasE=";
      targetNamespace = "flux-system";
      createNamespace = true;
      # HelmChart has no dependency field; retry if the operator's CRD isn't ready yet.
      extraFieldDefinitions.spec.failurePolicy = "retry";
      values.instance.sync = {
        kind = "GitRepository";
        url = "https://github.com/trent-maetzold/homelab.git";
        ref = "refs/heads/main";
        path = "clusters/nidavellir";
      };
    };

    cloudnative-pg = {
      name = "cloudnative-pg";
      repo = "https://cloudnative-pg.github.io/charts";
      version = "0.29.2";
      hash = "sha256-nfPwdOyqivECd60VWJlHBhjqmlZdfHxIGHvceIdlWWA=";
      targetNamespace = "cnpg-system";
      createNamespace = true;
    };
  };
}
