# The `hosts` option from flake.hosts: each host's tailnet address.
{lib}: hosts: lib.mapAttrs (_: host: {ips.tailnet = host.tailnetIp;}) (lib.filterAttrs (_: host: host.tailnetIp != null) hosts)
