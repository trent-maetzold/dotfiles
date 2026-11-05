# Dotfiles

Personal configuration managed with [chezmoi](https://www.chezmoi.io/) and [mise](https://mise.jdx.dev/), on top of Omarchy's defaults.

## New machine

Install mise and chezmoi, then run `chezmoi init --apply https://github.com/trent-maetzold/dotfiles.git` and `mise install`. Review `chezmoi diff` before applying later changes. Omarchy itself provides the desktop defaults and system-wide mise tools.

The Hyprland monitor configuration is applied only on hostname `muninn`. Other hosts keep their own monitor configuration. To add another host, adjust `.chezmoiignore` and use a template or separate host-specific file.

## Desktop applications

Magpie and Paseo are declared as AUR packages in mise's `[bootstrap.packages]` (rather than as mise tools), so their desktop integration and dependencies are managed by pacman. On Omarchy/Arch, review the AUR PKGBUILDs first, then run `mise bootstrap packages apply --manager aur`. This requires `yay` or `paru` and sudo access. Unlike `mise install`, bootstrap packages are not installed automatically by `chezmoi apply`.

Magpie's selected preferences are merged into `settings.json` by `dot_config/private_magpie/modify_private_settings.json`. Edit that script to change managed preferences; do not run `chezmoi add` on the whole Magpie directory. Other settings and runtime state are preserved on each machine. Accounts, provider data, credentials, backups, caches, and usage history are not tracked.

## Maintenance

- Edit a managed file with `chezmoi edit ~/.config/mise/config.toml`, then `chezmoi diff` and `chezmoi apply`.
- Add deliberate personal changes with `chezmoi add <path>`; review for secrets and machine-specific settings first.
- Commit changes from the source directory (`chezmoi cd`).
