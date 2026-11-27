{inputs, ...}: {
  flake.modules.homeManager = {
    inherit (inputs.zoldt-agents.modules.homeManager) ai claude desktop-magpie magpie-cli paseo pi;
    inherit (inputs.zoldt-secrets.modules.homeManager) keyring rbw;
    dotfiles = inputs.zoldt-dotfiles.modules.homeManager.sync;
  };
}
