# Dotfiles

Personal configuration managed with [chezmoi](https://www.chezmoi.io/) and [mise](https://mise.jdx.dev/), on top of Omarchy's defaults.

## New machine

Install mise and chezmoi, then run `chezmoi init --apply <repository-url>` and `mise install`. Review `chezmoi diff` before applying later changes. Omarchy itself provides the desktop defaults and system-wide mise tools.

## Maintenance

- Edit a managed file with `chezmoi edit ~/.config/mise/config.toml`, then `chezmoi diff` and `chezmoi apply`.
- Add deliberate personal changes with `chezmoi add <path>`; review for secrets and machine-specific settings first.
- Commit changes from the source directory (`chezmoi cd`).
