{
  config,
  lib,
  pkgs,
  ...
}: {
  # Local VTODO files; vdirsyncer can sync this directory to a CalDAV server.
  accounts.calendar.basePath = "${config.xdg.dataHome}/todo";
  programs.todoman = {
    enable = true;
    extraConfig = ''
      default_list = "tasks"
      default_due = 0
      date_format = "%Y-%m-%d"
      time_format = "%H:%M"
    '';
  };
  home.packages = [pkgs.vdirsyncer];
  home.activation.todoDirectory = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${config.xdg.dataHome}/todo/tasks"
  '';
}
