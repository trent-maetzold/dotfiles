#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["typer", "pydantic-settings", "python-dotenv", "gitpython", "sh"]
# [tool.uv]
# exclude-newer = "2026-11-10T00:00:00Z"  # pins the resolution; bump to update
# ///
"""Copy each NAME=<source> line of DIR/secrets.sources into DIR/secrets.yaml as
the sops key NAME, then commit DIR if it changed. Sources:

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
from dotenv import dotenv_values
from git import Repo
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    sops_age_key_file: Path = Path.home() / ".config/age/keys.txt"
    ksm_config_file: Path | None = None


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
    return next(f["value"][0] for f in fields if field in (f.get("type"), f.get("label")))


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
        env["KSM_CONFIG"] = base64.b64encode(settings.ksm_config_file.read_bytes()).decode()
    output = vault.ksm.exec("--", "env", "-0", _env={**os.environ, **env})
    resolved = dict(pair.split("=", 1) for pair in output.split("\0") if "=" in pair)
    if unresolved := [n for n in refs if resolved.get(n, "keeper://").startswith("keeper://")]:
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
            raise typer.Exit(f"sync-secrets: {name}: cannot read {source} ({why(e)})") from e
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


def main(directory: Annotated[Path, typer.Argument(exists=True, file_okay=False)] = Path(".")) -> None:
    os.chdir(directory)
    os.environ["SOPS_AGE_KEY_FILE"] = str(settings.sops_age_key_file)
    sources = {name: value or "" for name, value in dotenv_values("secrets.sources", interpolate=False).items()}

    # Keeper: log in once (turning on persistent login) if the saved session expired.
    if any(s.startswith("keeper:") for s in sources.values()) and not keeper_logged_in():
        sh.keeper("this-device", "register", _fg=True)
        sh.keeper("this-device", "persistent-login", "on", _fg=True)

    # Values travel over pipes only, never argv.
    for name, value in resolve(sources).items():
        sh.sops.set("--idempotent", "--value-stdin", "secrets.yaml", f'["{name}"]', _in=json.dumps(value), _err=sys.stderr)

    repo = Repo(".")
    if repo.is_dirty(path="secrets.yaml"):
        repo.git.commit("-qm", "sync-secrets", "--", "secrets.yaml", "secrets.sources")
        print("sync-secrets: committed; update the flake input that points here")
    else:
        print("sync-secrets: no changes")


if __name__ == "__main__":
    typer.run(main)
