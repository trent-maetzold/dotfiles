{
  config,
  lib,
  pkgs,
  infra,
  sops-nix,
  ...
}: let
  keyCommand = "${config.programs.rbw.package}/bin/rbw get age-master";
in {
  imports = [sops-nix.homeManagerModules.sops];

  home.packages = [pkgs.sops];
  home.sessionVariables.SOPS_AGE_KEY_CMD = keyCommand;

  sops = {
    defaultSopsFile = "${infra}/secrets.yaml";
    age = {
      # shortcut: empty file satisfies sops-nix's assertion; drop when command-only keys are accepted.
      keyFile = "/dev/null";
      sshKeyPaths = [];
    };
    gnupg.sshKeyPaths = [];
    environment = {
      SOPS_AGE_KEY = "";
      SOPS_AGE_KEY_CMD = keyCommand;
    };
    secrets = {
      "shared/codeberg-token" = {};
      "shared/deepseek-api-key" = {};
    };
  };

  systemd.user.services.sops-nix = {
    Unit = {
      Requires = ["rbw-agent.service"];
      After = ["rbw-agent.service"];
    };
    # Login must not prompt for the vault password or leave a failed unit.
    Service.ExecCondition = "${config.programs.rbw.package}/bin/rbw unlocked";
  };

  # The upstream hook can restart the old unit before HM reloads systemd.
  home.activation.sops-nix = lib.mkForce (lib.hm.dag.entryAfter ["reloadSystemd"] ''
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    if ${config.systemd.user.systemctlPath} --user is-active --quiet default.target; then
      run ${config.systemd.user.systemctlPath} --user restart sops-nix.service
    fi
  '');
}
