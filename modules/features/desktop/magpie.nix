{
  flake.modules.homeManager.desktop-magpie =
    # Magpie's desktop app: it *is* the gateway (the app runs `magpie serve`'s
    # engine itself). Select this or the headless magpie-cli aspect for a home.
    #
    # The unit below is what `magpie daemon install` writes (docs/reference.md,
    # "As a background service"), mirrored directive for directive so magpie's own
    # tooling still recognises it: the same file path
    # (`~/.config/systemd/user/magpie.service`), description, ordering, restart
    # policy and `WantedBy=default.target`. The one intended difference is the
    # binary: the desktop build's `magpie serve` rather than the CLI package's.
    # Keep it in step if that output changes — check with
    #   HOME=/tmp/x magpie daemon install --no-web && cat /tmp/x/.config/systemd/user/magpie.service
    #
    # It runs at login rather than with the graphical session, because the gateway
    # is what every agent talks to, not the window; on a host where agents work
    # before anyone logs in, set `users.users.<name>.linger = true;` (the
    # declarative `loginctl enable-linger`) so systemd starts it at boot. The app
    # opened by hand afterwards *uses* this service's gateway, so there is no port
    # fight. Don't run `magpie autostart on` here: its `~/.config/autostart/
    # magpie.desktop` hard-codes a store path and races this unit for the port.
    {
      config,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.magpie-desktop];

      systemd.user.services.magpie = {
        Unit = {
          Description = "magpie gateway";
          Wants = ["network-online.target"];
          After = ["network-online.target"];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.magpie-desktop}/bin/magpie-desktop serve";
          Restart = "on-failure";
          RestartSec = 5;
          Environment = [
            # `magpie daemon install` records the PATH it was installed from; on
            # Nix the profile directories are the equivalent, and through them the
            # agents and MCP servers it starts find node, bun and the agent CLIs.
            "PATH=/run/wrappers/bin:${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
          ];
        };
        Install.WantedBy = ["default.target"];
      };
    };
}
