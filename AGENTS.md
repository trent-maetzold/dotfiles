# Agent Instructions

## Issue Tracking

Use GitHub Issues in `zoldt/config.nix` for project task tracking. Run
`gh issue list` to find open work and `gh issue view <number>` to read an issue.

## Non-Interactive Shell Commands

Use non-interactive flags to avoid hanging on confirmation prompts.

- Use `cp -f`, `mv -f`, and `rm -f` for file operations that should proceed
  without prompting.
- Use `cp -rf` or `rm -rf` for recursive operations when intended.
- Use `-o BatchMode=yes` with `scp` and `ssh`.
- Use `-y` with `apt-get` and set `HOMEBREW_NO_AUTO_UPDATE=1` for `brew`.
