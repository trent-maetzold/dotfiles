# Local packages as an overlay (pkgs.<name>). When nixpkgs gains one, delete its line.
{
  bkt,
  fnox,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}: final: prev: {
  # Wrap a package to run under `fnox exec`; see ../lib/with-fnox.nix.
  withFnox = import ../lib/with-fnox.nix final;
  billion-context = final.callPackage ./billion-context {};
  # Patched so `bkt pr create` always adds the repo's default reviewers.
  bkt = bkt.packages.${final.stdenv.hostPlatform.system}.bkt.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./bitbucket-cli/default-reviewers.patch];
  });
  # Require an epic and assign the active Risk-YYYYMM sprint on issue creation.
  jira-cli-go = prev.jira-cli-go.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./jira-cli/risk-creation-defaults.patch];
  });
  confluence-cli = final.callPackage ./confluence-cli {};
  deepwiki-cli = final.callPackage ./deepwiki-cli {};
  fnox = fnox.packages.${final.stdenv.hostPlatform.system}.default;
  magpie-cli = final.callPackage ./magpie-cli {};
  mu-coding-agent = final.callPackage ./mu-coding-agent {};
  openwiki-cli = final.callPackage ./openwiki-cli {};
  tredis = final.callPackage ./tredis {};
  outlook-cli = final.callPackage ./outlook-cli {};
  inherit
    (final.callPackage ./keeper-cli {inherit uv2nix pyproject-nix pyproject-build-systems;})
    keeper-commander
    keeper-secrets-manager-cli
    ;
}
