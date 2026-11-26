{
  flake.modules.homeManager.ghostty = {
    # Use Ghostty for desktop actions that read TERMINAL.
    home.sessionVariables.TERMINAL = "ghostty";
    systemd.user.sessionVariables.TERMINAL = "ghostty";

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;
        # Split leftover pixels from the terminal's whole-cell grid across both edges.
        window-padding-balance = "equal";
      };
    };
  };
}
