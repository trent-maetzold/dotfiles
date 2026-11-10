"""fetch.py MANIFEST OUTDIR: write each Keeper field in MANIFEST to OUTDIR/<name>.
fetch.py (no args): log in to Keeper if the saved session can't resume.

MANIFEST maps name -> {"record": uid, "field": type or label}, e.g.
{"JIRA_API_TOKEN": {"record": "Abc...", "field": "password"}}.
Fetching only resumes Keeper Commander's saved session (~/.keeper/config.json)
and never prompts. Login mode runs Commander's interactive login in your
terminal and turns on persistent login, so later fetches resume silently.
"""
import json
import os
import sys

from keepercommander import api, cli, vault
from keepercommander.__main__ import get_params_from_config
from keepercommander.sync_down import sync_down


def value(record, field):
    if isinstance(record, vault.TypedRecord):
        if field == "notes":
            return record.notes
        f = record.get_typed_field(field) or record.get_typed_field(None, field)
        return None if f is None else f.get_default_value(str)
    if isinstance(record, vault.PasswordRecord):
        if field in ("login", "password", "link", "notes"):
            return getattr(record, field)
        return next((c.value for c in record.custom if c.name == field), None)
    return None


def resume(params):
    """Resume the saved session without prompting; True on success."""
    if not params.user:
        return False
    try:
        api.login(params)
    except (Exception, EOFError, KeyboardInterrupt):
        return False
    return bool(params.session_token)


def login():
    params = get_params_from_config()
    if resume(params):
        return
    print("keeper-secrets: log in to Keeper", file=sys.stderr)
    cli.do_command(params, "login")
    if not params.session_token:
        sys.exit("keeper-secrets: Keeper login failed")
    cli.do_command(params, "this-device register")
    cli.do_command(params, "this-device persistent-login on")


def fetch(manifest_path, outdir):
    with open(manifest_path) as f:
        manifest = json.load(f)
    params = get_params_from_config()
    if not resume(params):
        sys.exit("keeper-secrets: no Keeper session; run `just switch` (or `nix run <dotfiles>#switch`)")
    sync_down(params)

    os.umask(0o077)
    missing = []
    for name, ref in manifest.items():
        record = vault.KeeperRecord.load(params, ref["record"])
        v = None if record is None else value(record, ref["field"])
        if v is None:
            missing.append(f"{name} ({ref['record']}/{ref['field']})")
            continue
        with open(os.path.join(outdir, name), "w") as f:
            f.write(v)
    if missing:
        sys.exit("keeper-secrets: not found: " + ", ".join(missing))


if __name__ == "__main__":
    fetch(*sys.argv[1:3]) if len(sys.argv) > 1 else login()
