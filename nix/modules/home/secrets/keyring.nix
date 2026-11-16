# A Secret Service keyring for tools that store their own logins (gh, ...)
# on hosts without one (WSL): pass-secret-service over a gpg-encrypted pass
# store, unlocked by gpg-agent in the terminal. Desktops use gnome-keyring.
# One-time setup: `gpg --quick-gen-key <you>`, then `pass init <you>`.
{
  lib,
  osConfig ? {},
  pkgs,
  ...
}: {
  config = lib.mkIf (!(osConfig.services.gnome.gnome-keyring.enable or false)) {
    programs.password-store.enable = true;
    services.pass-secret-service.enable = true;
    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-curses;
    };
  };
}
