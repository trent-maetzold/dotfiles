# `outlook`: CLI for the outlook-classic-mcp server (Windows Outlook via COM,
# started through uvx.exe over WSL interop), via mcporter at runtime.
#   outlook                      list tools and their arguments
#   outlook list-mails limit=5   call outlook_list_mails
{ writeShellApplication, writeText, mcporter }:
let
  config = writeText "mcporter.json" (builtins.toJSON {
    mcpServers.outlook = {
      command = "uvx.exe";
      args = [ "--from" "outlook-classic-mcp" "outlook-mcp" ];
    };
  });
in
writeShellApplication {
  name = "outlook";
  runtimeInputs = [ mcporter ];
  text = ''
    case "''${1:-}" in
      "" | -h | --help | help) exec mcporter --config ${config} list outlook --schema ;;
    esac
    tool=''${1//-/_}
    shift
    exec mcporter --config ${config} call "outlook.outlook_''${tool#outlook_}" "$@"
  '';
}
