{ ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Trent Maetzold";
    };
  };

  programs.lazygit.enable = true;
}
