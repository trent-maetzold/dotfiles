{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.paseo.nixosModules.default];
  nixpkgs.overlays = [inputs.llm-agents.overlays.shared-nixpkgs];

  # Paseo inherits trent's profiles; keep the enabled provider CLIs available without Home Manager.
  environment.systemPackages = [
    pkgs.llm-agents.prime-agent
    inputs.autolith.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  users.users.trent.packages = [
    pkgs.llm-agents.claude-code
    # Use the cached build; the shared pin lacks AWS-LC's OpenSSL compatibility metadata.
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
    pkgs.llm-agents.pi
    pkgs.gh
  ];

  services.paseo = {
    enable = true;
    user = "trent";
    group = "users";
    listenAddress = "100.64.0.2";
    port = 6767;
    openFirewall = false;
    hostnames = ["paseo.ts.trkm.io"];

    relay = {
      enable = true;
      mode = "hosted";
      host = "";
      port = 443;
      useTls = true;
      publicUseTls = null;
    };

    settings = {
      version = 1;
      daemon = {
        cors.allowedOrigins = ["https://app.paseo.sh"];
        relay.enabled = false;
      };
      app.baseUrl = "https://app.paseo.sh";
      agents.providers = {
        prime-agent = {
          extends = "acp";
          label = "Prime Agent";
          description = "Prime Intellect self-improving RLM agent";
          command = ["prime-agent" "--mode" "acp"];
        };
        autolith = {
          extends = "acp";
          label = "Autolith";
          description = "Live, self-modifying Common Lisp agent";
          command = ["autolith" "acp"];
        };
        muse.enabled = false;
        antigravity.enabled = false;
        opencode.enabled = false;
        copilot.enabled = false;
      };
    };
  };
}
