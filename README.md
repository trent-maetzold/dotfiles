# NixOS dotfiles

Every machine is a host in this flake (`nix/hosts/<host>`, wired up in
`flake.nix`), with this repo checked out at `~/.config/dotfiles`. `<host>` and
`<user>` below stand for a host's name and its user.

Development tools are declared in `nix/modules/home/`; language toolchains live in
`nix/modules/home/dev/langs/` with XDG data/cache/state paths. The dotfiles flake uses
`import-tree` to import every module recursively, so new modules need no manual
import entries. Package expressions stay outside that tree in `nix/pkgs/`.
Magpie is a
pinned terminal-only binary; Paseo is the daemon/CLI package, not the desktop
app. Both run as systemd user services (`magpie.service` and `paseo.service`),
starting at login and restarting on failure. Magpie runs the gateway without a
web UI; Paseo runs its foreground daemon. Inspect them with:

```sh
systemctl --user status magpie paseo
journalctl --user -u magpie -u paseo -f
```

## Bootstrap a machine

Hosts installed straight from this flake live in `nix/hosts/<host>`, each
wired up in `flake.nix`. They build on the grouped NixOS modules in
`nix/modules/nixos`: `machine` (boot, locale, encrypted ephemeral-root disk,
trent as admin), `desktop`, `hardware`; `common`, `services` and `wsl` are for
WSL hosts.

| Host | Machine | Desktop |
| --- | --- | --- |
| `muninn` | trent's laptop | Niri + Noctalia, Home Manager for trent |
| `sif` | Justine's Yoga 720-13IKB | Cinnamon (X11), Flatpak apps via GNOME Software |

sif runs [comin](https://github.com/nlewo/comin) (`deploy/comin.nix`): it polls
`main` every 60 s and builds `nixosConfigurations.sif` when it changes, as the
default for the next boot: merging a PR updates the laptop at its next restart.
For an immediate change, `nixos-rebuild switch` over SSH still works. Push to `testing-sif` to try a config there
without keeping it across reboots. `comin status` on sif shows what it deployed.

From a NixOS live USB, install a host onto this machine. It offers to remove
all UEFI boot entries (firmware re-adds its built-in ones), runs the host's disko script (which asks
before wiping), asks for trent's login password and then the disk passphrase,
runs `nixos-install`, then enters the new system and sets trent's password. Users are managed imperatively from
there. `/` is wiped every boot; `/etc` is an overlay whose changes persist in
`/.rw-etc/upper`, so `ls -R /.rw-etc/upper` shows how `/etc` has drifted.

```sh
nix --extra-experimental-features 'nix-command flakes' run github:trent-maetzold/dotfiles#bootstrap -- muninn
```

Rebuild after changes with `nh os switch` (see [Rebuild](#rebuild)).

**sif:** first generate its hardware report from the live USB and commit it as
`nix/hosts/sif/facter.json` (`sudo nix run nixpkgs#nixos-facter -- -o facter.json`),
then bootstrap `sif`. After install, set Justine's password with
`sudo passwd justine`. SSH in as `ssh trent@sif.local` (keys only: the
Bitwarden keys `tm@nixos` and `trent@huginn`). Cinnamon's power and screensaver settings are defaults;
her own changes stick. Flathub is added for each user at their first login.

## Rebuild

`nh os switch` builds this checkout for the current hostname: Home Manager
points `NH_FLAKE` at `~/.config/dotfiles`. `just switch` first updates every
flake input and commits `flake.lock`.

## First login

From Windows PowerShell, use your distribution name from `wsl -l -q`:

```powershell
wsl -d <distribution> -u <user> --cd /home/<user>
```

Set a password if you want password-based login or sudo:

```sh
sudo passwd <user>
```

The original `nixos` account remains available. Neither account's password is
stored in this repository. Nushell is the default login shell for `<user>`;
start a new login session after rebuilding to use it.

## Neovim / LazyVim

`config/nvim/` contains the [LazyVim starter](https://github.com/LazyVim/starter).
Home Manager creates an out-of-store symlink from `~/.config/nvim` to
`~/.config/dotfiles/config/nvim`, so editor changes and `lazy-lock.json` live in this
repository. Keep the checkout at that path. Add new files to Git before rebuilding.

After rebuilding, run `nvim`; lazy.nvim installs LazyVim and its plugins on
first launch. Customize `config/nvim/lua/config/` and `config/nvim/lua/plugins/` directly.
Use a Nerd Font in your terminal for icons.

If the corporate proxy blocks plugin downloads, launch with direct access where
allowed:

```sh
env -u HTTPS_PROXY -u HTTP_PROXY -u https_proxy -u http_proxy -u ALL_PROXY nvim
```

## Windows CA export (WSL)

`just import-win-ca --output-file OUTPUT.pem` (app: `nix run .#import-win-ca -- --output-file OUTPUT.pem`;
`--output-file` defaults to `$IMPORT_WIN_CA_OUTPUT_FILE`) exports current public CA certificates from the
Windows Current User and Local Machine Root and intermediate stores. It excludes
expired/not-yet-valid and explicitly distrusted certificates, removes duplicates,
and exports no private keys. It requires WSL with Windows interop enabled.

Then add the bundle to the WSL host's config (`nix/hosts/<host>`) and rebuild:

```nix
security.pki.certificateFiles = [./windows-ca.pem];
```

This is an explicit snapshot, not automatic Windows trust synchronization.
Export again and rebuild after Windows CA changes. Review the trust scope before
importing: the bundle includes intermediate CAs, and Linux does not reproduce
Windows chain/revocation policies. This repo is public, and a corporate root CA
names your employer: decide before committing one.
The exporter itself does not change system trust or activate NixOS.

## Tmux

`nix/modules/home/term/tmux.nix` uses `Ctrl-b` as the prefix and follows Herdr's common
bindings: `v`/`-` split, `h/j/k/l` focus panes, Tab/Shift-Tab cycle panes,
`c` creates a tab, `n`/`p` switch tabs, `T` renames a tab, `X` closes a tab,
`x` closes a pane, `z` zooms, and `q` detaches. `r` enters resize mode
(hjkl/arrows; Enter/Escape finishes); `R` reloads the config.
Tmux sessions act as workspaces: `w` opens the picker, `N` creates one,
`W` renames it, and `D` closes it. All these keys follow the prefix.

## Python projects

Projects use direnv: an `.envrc` with `use mise` loads `mise.toml` (tools and env)
on entering the directory. Python packages with C extensions (psycopg2, gssapi) build on the
host: NixOS's nix-ld supplies their runtime libraries, and `pg_config`/`krb5-config`
are on PATH. uv passes gssapi the krb5 header path it needs
(`nix/modules/home/dev/langs/python.nix`).

## Updating

```sh
just switch # nix flake update, commit flake.lock, nh os switch
```

The current corporate proxy causes GitHub certificate errors. Where direct
access is allowed, fetch inputs without the proxy environment:

```sh
env -u HTTPS_PROXY -u HTTP_PROXY -u https_proxy -u http_proxy -u ALL_PROXY nix flake update
```

Otherwise install your organization's trusted CA; do not disable TLS verification.
Magpie's URL/version/hash are pinned separately in `nix/pkgs/magpie-cli/default.nix`.

## Secrets and SSH keys

Bitwarden, through [rbw](https://github.com/doy/rbw), on every host
(`nix/modules/home/secrets/rbw.nix`). `rbw unlock` starts `rbw-agent`, which
holds the unlocked vault and is also the SSH agent: SSH's `IdentityAgent` points
at `$XDG_RUNTIME_DIR/rbw/ssh-agent-socket`, which serves Bitwarden SSH-key items.
Private keys are never written to disk. Once per machine:

```sh
rbw config set email YOUR_BITWARDEN_EMAIL
rbw config set base_url https://vault.example.com # only if self-hosted
rbw register # first time on this device
rbw login
```

After each login, run `rbw unlock` before using SSH: it starts the agent and
asks for the master password through `pinentry` (graphical on desktops, in the
terminal elsewhere). When the vault relocks after rbw's lock timeout, SSH
prompts again where you last ran `rbw`.

Tools that save their own logins (`gh auth login`, ...) use the Secret Service
keyring: gnome-keyring on desktops, unlocked at login; elsewhere (WSL)
pass-secret-service over a gpg-encrypted `pass` store
(`nix/modules/home/secrets/keyring.nix`). Set that up once:

```sh
gpg --quick-gen-key "Trent Maetzold <EMAIL>"
pass init "<EMAIL>"
```

gpg-agent then asks for the key's passphrase in the terminal when a stored
login is first used.

The apps (`import-win-ca`) take each setting from a flag, else an env var, else
an env file (`$ENV_FILE`, default `./.env`); with none set they exit with an error.
