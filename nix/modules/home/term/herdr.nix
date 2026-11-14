{...}: {
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;
      terminal.default_shell = "nu";
      ui = {
        status_indicators = "symbols";
        toast.delivery = "terminal";
      };
      theme.name = "tokyo-night";
    };
  };
}
