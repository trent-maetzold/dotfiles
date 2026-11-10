# fnox: secrets as age-encrypted values (or remote references) in fnox.toml
# files. The host adds providers and the age recipient to programs.fnox.settings.
{
  config,
  pkgs,
  ...
}: {
  programs.fnox.enable = true;
  programs.fnox.settings.providers.age = {
    type = "age";
    key_file = "${config.xdg.configHome}/age/keys.txt";
  };
  # rage-keygen creates that key.
  home.packages = [pkgs.rage];
}
