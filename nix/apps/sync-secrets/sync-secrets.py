# /// script
# requires-python = ">=3.12"
# dependencies = ["typer", "pydantic-settings", "python-dotenv", "gitpython"]
# ///
"""Copy each NAME=<source> line of DIR/secrets.sources into DIR/secrets.yaml as
the sops key NAME, then commit DIR if it changed. Sources use secrets-env
syntax (keeper:<uid>[#field], ksm:keeper://..., rbw:...)."""

import json
import os
import subprocess
from pathlib import Path
from typing import Annotated

import typer
from dotenv import dotenv_values
from git import Repo
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    sops_age_key_file: Path = Path.home() / ".config/age/keys.txt"


def keeper_logged_in() -> bool:
    return subprocess.run(["keeper", "whoami"], stdin=subprocess.DEVNULL, capture_output=True).returncode == 0


def main(directory: Annotated[Path, typer.Argument(exists=True, file_okay=False)] = Path(".")) -> None:
    os.chdir(directory)
    os.environ["SOPS_AGE_KEY_FILE"] = str(Settings().sops_age_key_file)

    # Keeper: log in once (turning on persistent login) if the saved session expired.
    sources = dotenv_values("secrets.sources", interpolate=False)
    if any((ref or "").startswith("keeper:") for ref in sources.values()) and not keeper_logged_in():
        subprocess.run(["keeper", "this-device", "register"], check=True)
        subprocess.run(["keeper", "this-device", "persistent-login", "on"], check=True)

    # Values travel over pipes only, never argv.
    resolved = subprocess.run(["secrets-env", "--json", "secrets.sources"], stdout=subprocess.PIPE, text=True)
    if resolved.returncode:
        raise typer.Exit(resolved.returncode)
    for name, value in json.loads(resolved.stdout).items():
        subprocess.run(
            ["sops", "set", "--idempotent", "--value-stdin", "secrets.yaml", f'["{name}"]'],
            input=json.dumps(value), text=True, check=True,
        )

    repo = Repo(".")
    if repo.is_dirty(path="secrets.yaml"):
        repo.git.commit("-qm", "sync-secrets", "--", "secrets.yaml", "secrets.sources")
        print("sync-secrets: committed; update the flake input that points here")
    else:
        print("sync-secrets: no changes")


if __name__ == "__main__":
    typer.run(main)
