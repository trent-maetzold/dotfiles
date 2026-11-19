{pkgs, ...}: {
  programs.neovim.extraPackages = with pkgs; [docker-compose-language-service dockerfile-language-server];
}
