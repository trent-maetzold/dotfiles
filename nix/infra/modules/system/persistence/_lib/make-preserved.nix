# Preservation entries from `persistence` dirs or files; `key` is "directory" or "file".
{lib}: key: entries:
lib.mapAttrsToList (path: o: {
  ${key} = path;
  inherit (o) user group mode;
})
entries
