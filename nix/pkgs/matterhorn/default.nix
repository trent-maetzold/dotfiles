{
  haskell,
  haskellPackages,
}: let
  packages = haskellPackages.override {
    overrides = self: super: {
      mattermost-api = haskell.lib.markUnbroken (haskell.lib.overrideCabal super.mattermost-api (old: {
        libraryHaskellDepends = old.libraryHaskellDepends ++ [self.data-default];
        patches = (old.patches or []) ++ [./tls-settings.patch];
      }));
    };
  };
in
  haskell.lib.justStaticExecutables (haskell.lib.doJailbreak packages.matterhorn)
