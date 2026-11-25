{
  flake.modules.homeManager.secrets-keyring =
    # The Secret Service keyring, and the `pinentry` that rbw and gpg prompt with.
    # With gnome-keyring (desktops): a graphical pinentry. Without (WSL):
    # pass-secret-service over a gpg-encrypted pass store, unlocked by gpg-agent,
    # with a terminal pinentry. One-time setup there: `gpg --quick-gen-key <you>`,
    # then `pass init <you>`.
    {
      lib,
      osConfig ? {},
      pkgs,
      ...
    }: let
      gnomeKeyring = osConfig.services.gnome.gnome-keyring.enable or false;
      pinentry =
        if gnomeKeyring
        then pkgs.pinentry-qt
        else pkgs.pinentry-curses;
    in {
      config = lib.mkMerge [
        {home.packages = [pinentry];}

        (lib.mkIf (!gnomeKeyring) {
          programs.password-store.enable = true;
          services.pass-secret-service.enable = true;
          services.gpg-agent = {
            enable = true;
            pinentry.package = pinentry;
          };
        })
      ];
    };
}
