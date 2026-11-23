# trent administers every standalone machine. Bootstrap sets the first
# password; change it with `passwd`.
{
  users.users.trent = {
    isNormalUser = true;
    description = "Trent Maetzold";
    extraGroups = ["networkmanager" "wheel"];
    # Bitwarden SSH keys tm@nixos and trent@huginn (served by the SSH agent).
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIb8eWQl7Ck6RqwqRWZWGWcIEoz+7RjaOaQM/h0PrM7q heeler"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6sEj9jzEpu4Cbko4lLq54i16hM4RyIFmaIM5uZ2RH8"
    ];
  };
}
