{
  # The headless gateway. Select this or the desktop Magpie aspect for a home.
  flake.modules.homeManager.magpie-cli = import ./_magpie-cli.nix;
}
