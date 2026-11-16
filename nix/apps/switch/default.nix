# Update every input of this flake (NH_FLAKE), committing flake.lock, then
# switch. Args go to nh.
{
  pkgs,
  app,
}:
app "Update flake inputs, then nh os switch" (pkgs.lib.getExe (pkgs.writeShellApplication {
  name = "switch";
  runtimeInputs = [pkgs.nh];
  text = ''exec nh os switch --update --commit-lock-file "$@"'';
}))
