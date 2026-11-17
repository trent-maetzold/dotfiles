# The `persistence` dirs wanting snapshots.
{lib}: dirs: lib.filterAttrs (_: d: d.snapshots) dirs
