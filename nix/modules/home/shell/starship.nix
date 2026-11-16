{
  programs.starship = {
    enable = true;
    settings = {
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes = {
        symbol = "⛵";
        disabled = false;
      };
      os.disabled = false;
    };
  };
}
