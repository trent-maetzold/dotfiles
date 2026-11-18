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
    postPatch =
      (old.postPatch or "")
      + ''
        cp ${./bitbucket-cli/tests/default_reviewers_test.go} pkg/cmd/pr/required_defaults_test.go
      '';
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      go test ./pkg/cmd/pr -run '^TestRequiredDefaultReviewers$' -count=1
      runHook postCheck
    '';
  });
  # Require an epic, default to RD/self and assign the active Risk-YYYYMM sprint.
  jira-cli-go = prev.jira-cli-go.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./jira-cli/risk-creation-defaults.patch];
    postPatch =
      (old.postPatch or "")
      + ''
          cp ${./jira-cli/tests/risk_defaults_test.go} internal/cmd/issue/create/risk_defaults_test.go
          cp ${./jira-cli/tests/risk_command_test.go} internal/cmd/issue/create/risk_command_test.go
        cp ${./jira-cli/tests/risk_project_test.go} internal/cmd/root/risk_project_test.go
      '';
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      go test ./internal/cmd/issue/create -count=1
      go test ./internal/cmd/root -run '^TestRiskProject' -count=1
      runHook postCheck
    '';
  });
  confluence-cli = final.callPackage ./confluence-cli {};
  deepwiki-cli = final.callPackage ./deepwiki-cli {};
  fnox = fnox.packages.${final.stdenv.hostPlatform.system}.default;
  magpie-cli = final.callPackage ./magpie-cli {};
  matterhorn = final.callPackage ./matterhorn {};
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
