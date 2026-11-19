# Update every input of the local checkout, committing flake.lock, then
# switch. Args go to nh.
{
  pkgs,
  app,
}:
app "Update flake inputs, then nh os switch" (pkgs.lib.getExe (pkgs.writeShellApplication {
  name = "switch";
  runtimeInputs = [pkgs.nh];
  text = ''NH_OS_FLAKE=. exec nh os switch --update --commit-lock-file "$@"'';
}))
