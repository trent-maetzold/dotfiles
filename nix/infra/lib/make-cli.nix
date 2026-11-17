# Package installing a PEP 723 (`uv init --script`) script as `name`;
# pyproject-nix swaps its shebang for a Nix Python with its dependencies.
{pyproject-nix, ...}: {
  flake.lib.makeCli = {
    pkgs,
    name,
    script,
  }:
    pkgs.writeScriptBin name ((pyproject-nix.lib.scripts.loadScript {inherit name script;}).renderWithPackages {python = pkgs.python3;});
}
