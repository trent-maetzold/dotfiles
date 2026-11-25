# NixOS authorized keys for Trent; private keys are not stored here.
{
  users.users.trent.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds trent@muninn"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6sEj9jzEpu4Cbko4lLq54i16hM4RyIFmaIM5uZ2RH8 trent@huginn"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIb8eWQl7Ck6RqwqRWZWGWcIEoz+7RjaOaQM/h0PrM7q heeler"
  ];
}
