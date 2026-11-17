# Headscale A records pointing every route at one ip, public ones too (split DNS).
{lib}: ip: routes:
lib.mapAttrsToList (_: route: {
  name = route.hostname;
  type = "A";
  value = ip;
})
routes
