# Profile registry: hosts and users pull these by name, so a profile whose
# features were all deleted is empty instead of an eval error.
{
  flake = {
    homeModules = {
      default = {};
      default-slim = {};
      desktop = {};
      kids = {};
      infra = {};
    };

    nixosModules = {
      default = {};
      desktop = {};
      nvidia = {};
    };
  };
}
