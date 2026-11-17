# A `routes.<n>` value: traefik sends `hostname` to `ip:port`.
{
  flake.lib.makeServiceRoute = {
    hostname,
    ip,
    port,
    scheme ? "http",
    public ? false,
  }: {
    inherit hostname public;
    endpoint = {inherit ip port scheme;};
  };
}
