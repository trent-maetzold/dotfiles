{pkgs, ...}: {
  imports = [../../users/trent/ssh-keys.nix];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nidavellir";
  system.stateVersion = "26.11";

  microvm = {
    hypervisor = "qemu";
    vcpu = 4;
    mem = 6144;
    interfaces = [
      {
        type = "user";
        id = "nidavellir";
        mac = "02:00:00:00:64:01";
      }
    ];
    volumes = [
      {
        image = "nidavellir-state.img";
        mountPoint = "/var";
        size = 40960;
      }
    ];
    forwardPorts = [
      {
        host.address = "127.0.0.1";
        host.port = 2228;
        guest.port = 22;
      }
    ];
  };

  networking.useDHCP = true;
  networking.usePredictableInterfaceNames = false;
  networking.firewall = {
    interfaces.eth0.allowedTCPPorts = [22]; # QEMU forwards SSH on host loopback only.
    interfaces.tailscale0.allowedTCPPorts = [6443];
    # Pods (including CoreDNS and metrics-server) need the local API and kubelet.
    interfaces.cni0.allowedTCPPorts = [6443 10250];
  };
  services.openssh = {
    enable = true;
    openFirewall = false;
    hostKeys = [
      {
        path = "/var/lib/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = ["trent"];
    };
  };
  users.users.trent = {
    isNormalUser = true;
    home = "/var/lib/trent";
    extraGroups = ["wheel"];
  };
  security.sudo.wheelNeedsPassword = false;

  services.tailscale = {
    enable = true;
    openFirewall = false;
    # Keep the NixOS firewall in charge of which tailnet ports are reachable.
    extraSetFlags = ["--netfilter-mode=off"];
  };
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    configPath = "/run/k3s-nidavellir/config.yaml";
    disable = ["traefik" "servicelb"];
    extraFlags = [
      "--secrets-encryption"
      "--secrets-encryption-provider=secretbox"
      "--cluster-cidr=10.62.0.0/16"
      "--service-cidr=10.63.0.0/16"
      "--cluster-dns=10.63.0.10"
      "--flannel-backend=vxlan"
      "--flannel-iface=tailscale0"
      "--tls-san=nidavellir.ts.trkm.io"
    ];
  };

  # Wait for enrollment before choosing the address used by Kubernetes and etcd.
  systemd.services.k3s = {
    after = ["tailscaled.service"];
    wants = ["tailscaled.service"];
    serviceConfig.RuntimeDirectory = "k3s-nidavellir";
    preStart = ''
      umask 077
      until ip="$(${pkgs.tailscale}/bin/tailscale ip -4 2>/dev/null)" && [ -n "$ip" ]; do
        sleep 2
      done
      printf 'node-ip: "%s"\nadvertise-address: "%s"\n' "$ip" "$ip" > /run/k3s-nidavellir/config.yaml
    '';
  };
}
