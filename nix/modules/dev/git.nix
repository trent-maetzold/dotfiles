{ ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Trent Maetzold";
      email = "trent@maetzold.net";
    };
  };

  programs.lazygit.enable = true;
}
