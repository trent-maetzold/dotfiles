{user, ...}: {
  programs.git = {
    enable = true;
    settings.user = {
      name = user.fullName;
      inherit (user) email;
    };
  };

  programs.gh.enable = true;
  programs.lazygit.enable = true;
}
