#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["typer", "pydantic-settings", "python-dotenv", "gitpython", "sh"]
# [tool.uv]
# exclude-newer = "2026-11-10T00:00:00Z"  # pins the resolution; bump to update
# ///
"""Copy each NAME=<source> line of DIR/secrets.sources into DIR/secrets.yaml as
the sops key NAME, then commit DIR if it changed. Sources use secrets-env
syntax (keeper:<uid>[#field], ksm:keeper://..., rbw:...)."""

import json
import os
import sys
from pathlib import Path
from typing import Annotated

import sh
import typer
from dotenv import dotenv_values
from git import Repo
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    sops_age_key_file: Path = Path.home() / ".config/age/keys.txt"


def keeper_logged_in() -> bool:
    try:
        sh.keeper.whoami(_in="")
        return True
    except sh.ErrorReturnCode:
        return False


def main(directory: Annotated[Path, typer.Argument(exists=True, file_okay=False)] = Path(".")) -> None:
    os.chdir(directory)
    os.environ["SOPS_AGE_KEY_FILE"] = str(Settings().sops_age_key_file)

    # Keeper: log in once (turning on persistent login) if the saved session expired.
    sources = dotenv_values("secrets.sources", interpolate=False)
    if any((ref or "").startswith("keeper:") for ref in sources.values()) and not keeper_logged_in():
        sh.keeper("this-device", "register", _fg=True)
        sh.keeper("this-device", "persistent-login", "on", _fg=True)

    # Values travel over pipes only, never argv.
    try:
        resolved = sh.Command("secrets-env")("--json", "secrets.sources", _err=sys.stderr)
    except sh.ErrorReturnCode as e:
        raise typer.Exit(e.exit_code) from e
    for name, value in json.loads(resolved).items():
        sh.sops.set("--idempotent", "--value-stdin", "secrets.yaml", f'["{name}"]', _in=json.dumps(value))

    repo = Repo(".")
    if repo.is_dirty(path="secrets.yaml"):
        repo.git.commit("-qm", "sync-secrets", "--", "secrets.yaml", "secrets.sources")
        print("sync-secrets: committed; update the flake input that points here")
    else:
        print("sync-secrets: no changes")


if __name__ == "__main__":
    typer.run(main)
