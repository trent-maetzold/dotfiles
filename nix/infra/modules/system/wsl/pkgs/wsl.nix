# `wslview`, which xdg-utils calls on WSL, opening through wsl-open; and an empty
# nvidia driver, since WSL mounts the Windows one.
{
  flake.overlays.wsl = final: _: {
    wslview = final.writeShellScriptBin "wslview" ''exec wsl-open "$@"'';
    wsl-nvidia-driver-stub = final.runCommand "wsl-nvidia-driver-stub" {outputs = ["out" "lib"];} "mkdir -p $out $lib";
  };
}
