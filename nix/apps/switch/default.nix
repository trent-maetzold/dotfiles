# Update every input of the host flake (programs.nh.flake, else pass one),
# committing flake.lock, then switch. Args go to nh.
{
  pkgs,
  app,
}:
app "Update flake inputs, then nh os switch" (pkgs.writeShellApplication {
  name = "switch";
  runtimeInputs = [pkgs.nh];
  text = ''exec nh os switch --update --commit-lock-file "$@"'';
})
