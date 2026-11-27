{
  flake.modules.homeManager.atuin =
    # Shell history in sqlite, owns Ctrl-R.
    {
      programs.atuin.enable = true;
      programs.fzf.historyWidget.command = "";
    };
}
