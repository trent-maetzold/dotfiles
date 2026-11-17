# `docker` running podman, for tools that shell out to it without the Docker API socket.
{
  flake.overlays.docker-compat = final: _: {
    docker-compat = final.writeShellScriptBin "docker" ''exec ${final.podman}/bin/podman "$@"'';
  };
}
