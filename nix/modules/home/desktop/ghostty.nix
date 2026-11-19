{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      # Split leftover pixels from the terminal's whole-cell grid across both edges.
      window-padding-balance = "equal";
    };
  };
}
