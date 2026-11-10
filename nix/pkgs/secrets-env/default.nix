# Resolve .env.secrets references from the vault CLIs on PATH (ksm, keeper,
# rbw, sops, age) into shell exports; see secrets-env.py.
{writers}:
# shortcut: libraries repeat the script's PEP 723 dependencies; keep them in sync.
writers.writePython3Bin "secrets-env" {
  libraries = ps: with ps; [typer pydantic pydantic-settings python-dotenv];
  flakeIgnore = ["E501"];
} (builtins.readFile ./secrets-env.py)
