# trent administers every standalone machine. Bootstrap sets the first
# password; change it with `passwd`.
{
  users.users.trent = {
    isNormalUser = true;
    description = "Trent Maetzold";
    extraGroups = ["networkmanager" "wheel"];
  };
}
