# `outlook`: CLI for the outlook-classic-mcp server (Windows Outlook via COM,
# started through uvx.exe over WSL interop). outlook.ts is generated, because
# mcporter needs the live server to discover tools. Regenerate after server updates:
#   mcporter generate-cli --command 'uvx.exe --from outlook-classic-mcp outlook-mcp' \
#     --name outlook --output outlook.ts --runtime bun
#   sed -i -e 's#"cwd": "[^"]*",##; s#\\"cwd\\":\\"[^"]*\\",##g' -e '/"outlook-\(classic-\)\?mcp"/!s/"outlook-\([a-z-]*\)"/"\1"/g' outlook.ts
{ runCommand, makeWrapper, bun, mcporter }:
let mcp = "${mcporter}/lib/node_modules/mcporter";
in
runCommand "outlook-cli" { nativeBuildInputs = [ makeWrapper ]; meta.mainProgram = "outlook"; } ''
  mkdir -p $out/lib/outlook/node_modules $out/bin
  cp ${./outlook.ts} $out/lib/outlook/outlook.ts
  # Resolve mcporter and commander from nixpkgs' mcporter.
  ln -s ${mcp} $out/lib/outlook/node_modules/mcporter
  ln -s ${mcp}/node_modules/commander $out/lib/outlook/node_modules/commander
  makeWrapper ${bun}/bin/bun $out/bin/outlook --add-flags $out/lib/outlook/outlook.ts
''
