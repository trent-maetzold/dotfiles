#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["typer", "pydantic-settings", "python-dotenv", "sh"]
# [tool.uv]
# exclude-newer = "2026-11-10T00:00:00Z"  # pins the resolution; bump to update
# ///
"""Copy each NAME=<source> line of the sources file (--input-file) into the sops file
(--output-file, which must exist, in any format sops edits) as the key NAME.
The decryption key comes from --sops-key-file (age, SSH or PGP), else sops's own lookup. Sources:

    API_TOKEN=keeper:<record-uid>                         Keeper Commander, password field
    JIRA_TOKEN=keeper:<record-uid>#note                   ... or a field by type or label, notes, or file (its one attachment)
    DB_PASSWORD=ksm:keeper://<record-uid>/field/password  Keeper Secrets Manager (KSM_CONFIG line, else KSM_CONFIG_FILE)
    GH_TOKEN=rbw:github                                   Bitwarden via rbw: password, or rbw:<entry>#<field>

Nothing is written unless every source resolves.
"""

import base64
import json
import os
import sys
import tempfile
from pathlib import Path
from typing import Annotated

import sh
import typer
from dotenv import dotenv_values, load_dotenv
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    ksm_config_file: Path | None = None


# sops reads each file-based key type from its own env var; PGP keys go through gpg.
SOPS_KEY_VARS = {
    "AGE-SECRET-KEY-": "SOPS_AGE_KEY_FILE",
    "-----BEGIN OPENSSH PRIVATE KEY-----": "SOPS_AGE_SSH_PRIVATE_KEY_FILE",
    "-----BEGIN RSA PRIVATE KEY-----": "SOPS_AGE_SSH_PRIVATE_KEY_FILE",
}


def use_sops_key(key_file: Path, gnupg_home: str) -> None:
    """Point sops at key_file, whatever kind of key it is."""
    key = key_file.read_text()
    if "-----BEGIN PGP PRIVATE KEY BLOCK-----" in key:
        os.environ["GNUPGHOME"] = gnupg_home  # throwaway keyring, so yours is untouched
        sh.gpg("--batch", "--quiet", "--import", key_file)
        return
    var = next((v for marker, v in SOPS_KEY_VARS.items() if marker in key), None)
    if var is None:
        raise typer.Exit(
            f"sync-secrets: {key_file}: not an age, SSH or PGP private key"
        )
    os.environ[var] = str(key_file)


settings = Settings()
# Vault CLIs get empty stdin, so a locked vault fails instead of prompting, and
# a piped stdout, so keeper prints plain JSON.
vault = sh.bake(_in="", _tty_out=False)


def keeper(ref: str) -> str:
    uid, _, field = ref.partition("#")
    if field in ("", "password"):
        return vault.keeper.get(uid, "--format", "password").rstrip("\n")
    if field == "file":
        with tempfile.TemporaryDirectory() as tmp:
            vault.keeper("download-attachment", uid, "--out-dir", tmp)
            [attachment] = Path(tmp).iterdir()  # exactly one attachment
            return attachment.read_text()
    record = json.loads(vault.keeper.get(uid, "--format", "json", "--unmask"))
    if field == "notes":
        return record["notes"]
    fields = record.get("fields", []) + record.get("custom", [])
    return next(
        f["value"][0] for f in fields if field in (f.get("type"), f.get("label"))
    )


def rbw(ref: str) -> str:
    entry, _, field = ref.partition("#")
    return vault.rbw.get(*(["--field", field] if field else []), entry).rstrip("\n")


def ksm(refs: dict[str, str], values: dict[str, str]) -> dict[str, str]:
    """One `ksm exec` for every ksm: line: it swaps keeper:// values in its env for secrets."""
    env = dict(refs)
    # The ksm CLI takes its config in KSM_CONFIG; a KSM_CONFIG source line bootstraps it.
    if "KSM_CONFIG" in values:
        env["KSM_CONFIG"] = values["KSM_CONFIG"]
    elif settings.ksm_config_file and settings.ksm_config_file.is_file():
        env["KSM_CONFIG"] = base64.b64encode(
            settings.ksm_config_file.read_bytes()
        ).decode()
    output = vault.ksm.exec("--", "env", "-0", _env={**os.environ, **env})
    resolved = dict(pair.split("=", 1) for pair in output.split("\0") if "=" in pair)
    if unresolved := [
        n for n in refs if resolved.get(n, "keeper://").startswith("keeper://")
    ]:
        raise ValueError(f"ksm did not resolve {', '.join(unresolved)}")
    return {n: resolved[n] for n in refs}


def why(error: Exception) -> str:
    """A failed CLI's stderr; never its stdout, which may hold secrets."""
    if isinstance(error, sh.ErrorReturnCode):
        return error.stderr.decode().strip() or f"exit {error.exit_code}"
    return str(error)


def resolve(sources: dict[str, str]) -> dict[str, str]:
    values: dict[str, str] = {}
    ksm_refs: dict[str, str] = {}
    for name, source in sources.items():
        scheme, _, ref = source.partition(":")
        if scheme == "ksm":
            ksm_refs[name] = ref
            continue
        try:
            values[name] = {"keeper": keeper, "rbw": rbw}[scheme](ref)
        except Exception as e:
            raise typer.Exit(
                f"sync-secrets: {name}: cannot read {source} ({why(e)})"
            ) from e
    if ksm_refs:
        try:
            values |= ksm(ksm_refs, values)
        except Exception as e:
            raise typer.Exit(f"sync-secrets: ksm failed ({why(e)})") from e
    return values


def keeper_logged_in() -> bool:
    try:
        vault.keeper.whoami()
        return True
    except sh.ErrorReturnCode:
        return False


def main(
    infile: Annotated[
        Path,
        typer.Option(
            "--input-file",
            envvar="SYNC_SECRETS_INPUT_FILE",
            exists=True,
            dir_okay=False,
            help="NAME=<source> lines.",
        ),
    ],
    outfile: Annotated[
        Path,
        typer.Option(
            "--output-file",
            envvar="SYNC_SECRETS_OUTPUT_FILE",
            exists=True,
            dir_okay=False,
            help="sops file to update.",
        ),
    ],
    sops_key_file: Annotated[
        Path | None,
        typer.Option(
            envvar="SYNC_SECRETS_SOPS_KEY_FILE",
            exists=True,
            dir_okay=False,
            help="age, SSH or PGP private key; default: sops's own lookup.",
        ),
    ] = None,
) -> None:
    gnupg_home = tempfile.TemporaryDirectory()
    if sops_key_file:
        use_sops_key(sops_key_file, gnupg_home.name)
    sources = {
        name: value or ""
        for name, value in dotenv_values(infile, interpolate=False).items()
    }

    # Keeper: log in once (turning on persistent login) if the saved session expired.
    if (
        any(s.startswith("keeper:") for s in sources.values())
        and not keeper_logged_in()
    ):
        sh.keeper("this-device", "register", _fg=True)
        sh.keeper("this-device", "persistent-login", "on", _fg=True)

    # Values travel over pipes only, never argv.
    for name, value in resolve(sources).items():
        sh.sops.set(
            "--idempotent",
            "--value-stdin",
            outfile,
            f'["{name}"]',
            _in=json.dumps(value),
            _err=sys.stderr,
        )
    typer.echo(f"sync-secrets: {len(sources)} secrets in {outfile}", err=True)


if __name__ == "__main__":
    # Settings: flags, else env vars, else an env file ($ENV_FILE, default ./.env).
    load_dotenv(os.environ.get("ENV_FILE", ".env"))
    typer.run(main)
