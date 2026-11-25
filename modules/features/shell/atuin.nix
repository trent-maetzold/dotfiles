{
  flake.modules.homeManager.shell-atuin =
    # Shell history in sqlite, owns Ctrl-R.
    {
      programs.atuin.enable = true;
      programs.fzf.historyWidget.command = "";
    };
}
