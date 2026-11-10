#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["typer", "cryptography"]
# [tool.uv]
# exclude-newer = "2026-11-10T00:00:00Z"  # pins the resolution; bump to update
# ///
"""Export the Windows Root/intermediate CAs (from WSL) to a PEM bundle: valid
CA certificates only, minus anything in the Disallowed store."""

import base64
import datetime
import json
import os
import subprocess
import tempfile
import warnings
from pathlib import Path
from typing import Annotated

import typer
from cryptography import x509
from cryptography.hazmat.primitives.hashes import SHA256
from cryptography.hazmat.primitives.serialization import Encoding
from cryptography.utils import CryptographyDeprecationWarning

# Some Windows roots have non-positive serial numbers; cryptography still loads them.
warnings.filterwarnings("ignore", category=CryptographyDeprecationWarning)


WINDOWS_CAS = Path(__file__).with_name("windows-cas.py")


def is_valid_ca(cert: x509.Certificate) -> bool:
    now = datetime.datetime.now(datetime.UTC)
    try:
        is_ca = cert.extensions.get_extension_for_class(x509.BasicConstraints).value.ca
    except x509.ExtensionNotFound:
        return False
    return is_ca and cert.not_valid_before_utc <= now < cert.not_valid_after_utc


def main(out: Annotated[Path, typer.Argument(help="PEM bundle to write.")]) -> None:
    script = subprocess.run(["wslpath", "-w", WINDOWS_CAS], capture_output=True, text=True, check=True).stdout.strip()
    stores = json.loads(subprocess.run(["uv.exe", "run", "--no-project", "--script", script], capture_output=True, text=True, check=True).stdout)

    def load(store: str) -> set[x509.Certificate]:
        return {x509.load_der_x509_certificate(base64.b64decode(der)) for der in stores[store]}

    trusted = (load("ROOT") | load("CA")) - load("Disallowed")
    certs = sorted((c for c in trusted if is_valid_ca(c)), key=lambda c: c.fingerprint(SHA256()))  # stable order, so reruns diff cleanly
    if not certs:
        raise typer.Exit("No valid Windows CA certificates found.")

    # Write beside the target, then rename, so a failed run never leaves half a bundle.
    out = out.resolve()
    with tempfile.NamedTemporaryFile("wb", dir=out.parent, delete=False) as tmp:
        tmp.writelines(c.public_bytes(Encoding.PEM) for c in certs)
    os.replace(tmp.name, out)
    typer.echo(f"Exported {len(certs)} public CA certificates to {out}", err=True)


if __name__ == "__main__":
    typer.run(main)
