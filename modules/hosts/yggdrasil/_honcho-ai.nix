# Honcho's Python SDK; call it from Hermes' sealed venv, which has its httpx/pydantic.
{
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "honcho_ai";
  version = "2.7.0";
  format = "wheel";
  src = fetchPypi {
    inherit pname version format;
    dist = "py3";
    python = "py3";
    hash = "sha256-zCRXjhhFBnPs5T7ixMWW5AQizcUoGJWTSSA5DYO2WXs=";
  };
  dontCheckRuntimeDeps = true;
}
