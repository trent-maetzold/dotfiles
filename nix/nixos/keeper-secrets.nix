# Keeper vault fields as files under /run/keeper-secrets/<name>, like agenix
# and sops-nix but fetched with your Keeper Commander login:
#
#   keeper.user = "me";
#   keeper.secrets.JIRA_API_TOKEN.record = "<record uid>";  # field defaults to password
#
# Log in once with `keeper-secrets-login` (persistent login); `switch` then
# fetches them during activation without prompting. Activation can't prompt:
# nh runs it outside the terminal's foreground, so reads fail. Boot activation
# runs before the network, so keeper-secrets.service fetches then.
# Needs the dotfiles overlay (pkgs.keeper-secrets).
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.keeper;
  manifest =
    pkgs.writeText "keeper-secrets.json" (builtins.toJSON
      (lib.mapAttrs (_: s: {inherit (s) record field owner group mode;}) cfg.secrets));
  sync = pkgs.writeShellScriptBin "keeper-secrets-sync" ''
    exec ${lib.getExe pkgs.keeper-secrets} ${cfg.user} ${manifest}
  '';
in {
  options.keeper = {
    user = mkOption {
      type = types.str;
      description = "Account whose Keeper Commander session (~/.keeper/config.json) fetches the secrets.";
    };
    secrets = mkOption {
      default = {};
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          record = mkOption {
            type = types.str;
            description = "Keeper record UID.";
          };
          field = mkOption {
            type = types.str;
            default = "password";
            description = "Field type (password, login, url, ...), custom field label, or notes.";
          };
          owner = mkOption {
            type = types.str;
            default = cfg.user;
          };
          group = mkOption {
            type = types.str;
            default = "root";
          };
          mode = mkOption {
            type = types.str;
            default = "0400";
          };
          path = mkOption {
            type = types.str;
            readOnly = true;
            default = "/run/keeper-secrets/${name}";
          };
        };
      }));
    };
  };

  config = lib.mkIf (cfg.secrets != {}) {
    # Refetch by hand, e.g. after adding a record: sudo keeper-secrets-sync
    environment.systemPackages = [sync pkgs.keeper-secrets];

    # Only on switch: at boot, systemd isn't running yet and neither is the network.
    system.activationScripts.keeper-secrets = {
      deps = ["users" "groups"];
      text = ''
        if [ -d /run/systemd/system ]; then
          ${lib.getExe sync} || echo "keeper-secrets: secrets not updated (see above)" >&2
        fi
      '';
    };

    systemd.services.keeper-secrets = {
      description = "Fetch Keeper secrets into /run/keeper-secrets";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # "-": a missing login mustn't fail the switch; the activation warning says why.
        ExecStart = "-${lib.getExe sync}";
      };
    };
  };
}
