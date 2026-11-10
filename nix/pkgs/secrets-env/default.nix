# Resolve .env.secrets references into shell exports; see secrets-env.py. A uv
# script, so it needs uv (and the vault CLIs it calls) on PATH.
{runCommandLocal}:
runCommandLocal "secrets-env" {meta.mainProgram = "secrets-env";} ''
  mkdir -p $out/bin
  ln -s ${./secrets-env.py} $out/bin/secrets-env
''
