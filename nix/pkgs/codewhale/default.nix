# Codewhale (formerly DeepSeek-TUI): a static release binary; not in nixpkgs or llm-agents.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "codewhale";
  version = "0.10.2";
  src = fetchurl {
    url = "https://github.com/codewhale-hq/Codewhale/releases/download/v${finalAttrs.version}/codewhale-linux-x64.tar.gz";
    hash = "sha256-7WZkcdhFVJySK7gIwB59VVPD6Xly13ykETmAAlEPcNk=";
  };
  installPhase = ''
    install -Dm755 codewhale $out/bin/codewhale
    ln -s codewhale $out/bin/codew
  '';
  meta = {
    description = "Terminal coding agent built for DeepSeek models";
    homepage = "https://github.com/codewhale-hq/Codewhale";
    mainProgram = "codewhale";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
