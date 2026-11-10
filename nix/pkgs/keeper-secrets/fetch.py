"""fetch.py MANIFEST OUTDIR: write each Keeper field in MANIFEST to OUTDIR/<name>.

MANIFEST maps name -> {"record": uid, "field": type or label}, e.g.
{"JIRA_API_TOKEN": {"record": "Abc...", "field": "password"}}.
Uses Keeper Commander's saved session (~/.keeper/config.json). When stdin is a
terminal and the session can't resume, it runs Commander's interactive login and
turns on persistent login, so the next non-interactive run resumes silently.
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


def main(manifest_path, outdir):
    with open(manifest_path) as f:
        manifest = json.load(f)
    params = get_params_from_config()
    interactive = sys.stdin.isatty()
    try:
        if params.user:
            api.login(params)
    except (Exception, EOFError, KeyboardInterrupt) as e:
        if not interactive:
            sys.exit(f"keeper-secrets: Keeper session expired ({e}); run `sudo keeper-secrets-sync` in a terminal")
    if not params.session_token:
        if not interactive:
            sys.exit("keeper-secrets: not logged in to Keeper; run `sudo keeper-secrets-sync` in a terminal")
        print("keeper-secrets: log in to Keeper", file=sys.stderr)
        cli.do_command(params, "login")
        if not params.session_token:
            sys.exit("keeper-secrets: Keeper login failed")
        cli.do_command(params, "this-device register")
        cli.do_command(params, "this-device persistent-login on")
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
    main(*sys.argv[1:3])
