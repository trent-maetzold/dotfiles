# One agent skill directory: SKILL.md plus its scripts/ and references/.
{
  lib,
  linkFarm,
  runCommand,
  writeTextFile,
  name,
  description,
  text,
  scripts ? {},
  references ? {},
}: let
  file = dir: executable: n: content: {
    name = "${name}/${dir}/${n}";

    path =
      if builtins.isPath content
      then content
      else
        writeTextFile {
          name = n;
          text = content;
          inherit executable;
        };
  };
in
  runCommand "skill-${name}" {} "cp -rL ${linkFarm name (
    [(file "." false "SKILL.md" "---\nname: ${name}\ndescription: ${builtins.toJSON description}\n---\n\n${text}")]
    ++ lib.mapAttrsToList (file "scripts" true) scripts
    ++ lib.mapAttrsToList (file "references" false) references
  )} $out"
