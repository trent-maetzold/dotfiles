# tredis: terminal UI for Redis. Not in nixpkgs.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tredis";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "huseyinbabal";
    repo = "tredis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AKyQQ7W0LOsxGUtGxnOAN90SaGAQC4ReYjtAXN9+lYQ=";
  };

  cargoHash = "sha256-5EMxHYwEj4lGFMK37HfOeJ5ombZ2KyTor4qSvom30P0=";

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];
  env.OPENSSL_NO_VENDOR = true;

  meta = {
    description = "Terminal UI for Redis";
    homepage = "https://github.com/huseyinbabal/tredis";
    license = lib.licenses.mit;
    mainProgram = "tredis";
  };
})
