{
  inputs,
  pkgs,
  ...
}: let
  checkVault = pkgs.writeShellApplication {
    name = "check-vault";
    runtimeInputs = [pkgs.rbw pkgs.sops];
    text = builtins.readFile ../../lib/check-vault.sh;
  };
in {
  system.preSwitchChecks.bitwarden = ''
    # Installing a system/bootloader does not have a logged-in user vault.
    if [ "$2" != boot ]; then
      ${pkgs.util-linux}/bin/runuser --user trent -- \
        ${pkgs.coreutils}/bin/env -i \
        HOME=/home/trent XDG_CONFIG_HOME=/home/trent/.config \
        XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u trent)" \
        ${checkVault}/bin/check-vault ${inputs.infra}/secrets.yaml
    fi
  '';
}
