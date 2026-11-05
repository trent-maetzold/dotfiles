# Dotfiles

Personal configuration managed with [chezmoi](https://www.chezmoi.io/) and [mise](https://mise.jdx.dev/), on top of Omarchy's defaults.

## New machine

Install mise and chezmoi, then run `chezmoi init --apply https://github.com/trent-maetzold/dotfiles.git` and `mise install`. Review `chezmoi diff` before applying later changes. Omarchy itself provides the desktop defaults and system-wide mise tools.

The Hyprland monitor configuration is applied only on hostname `muninn`. Other hosts keep their own monitor configuration. To add another host, adjust `.chezmoiignore` and use a template or separate host-specific file.

## Desktop applications

Magpie and Paseo are desktop apps, not mise registry tools. On Omarchy/Arch, their AUR desktop packages can be installed with `omarchy pkg aur add magpie-bin paseo-bin` after reviewing their PKGBUILDs. Their accounts and credentials are intentionally not managed here.

## Maintenance

- Edit a managed file with `chezmoi edit ~/.config/mise/config.toml`, then `chezmoi diff` and `chezmoi apply`.
- Add deliberate personal changes with `chezmoi add <path>`; review for secrets and machine-specific settings first.
- Commit changes from the source directory (`chezmoi cd`).
