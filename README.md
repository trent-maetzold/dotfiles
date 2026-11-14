# NixOS dotfiles

The standalone laptop configuration is `muninn` in `nix/hosts/muninn`.
Downstream WSL hosts can also import these modules from their own system flake
at `~/.config/nixos`; the WSL instructions below refer to that layout.

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
wired up (with its Home Manager `home.nix`) in `flake.nix`.

From a NixOS live USB, install a host onto this machine. It offers to remove
all UEFI boot entries (firmware re-adds its built-in ones), runs the host's disko script (which asks
before wiping), asks for trent's login password and then the disk passphrase,
runs `nixos-install`, then enters the new system and sets trent's password. Users are managed imperatively from
there. `/` is wiped every boot; `/etc` is an overlay whose changes persist in
`/.rw-etc/upper`, so `ls -R /.rw-etc/upper` shows how `/etc` has drifted.

```sh
nix --extra-experimental-features 'nix-command flakes' run github:trent-maetzold/dotfiles#bootstrap -- muninn
```

Rebuild after changes: `rbw unlock`, then
`sudo nixos-rebuild switch --flake ~/.config/dotfiles#muninn`.
The candidate configuration checks that the vault is unlocked and can decrypt
its pinned secrets before activation. Fresh installation/bootloader setup
(`boot`) is exempt because it has no logged-in user vault.

## Rebuild a downstream WSL host

```sh
sudo nixos-rebuild switch --flake ~/.config/nixos#<host>
```

Both repositories keep `flake.nix` and `flake.lock` at their root.
Dotfiles stores writable application configs in `config/` and Nix modules/packages
in `nix/`. The system flake lives in `~/.config/nixos/flake.nix`, with its host
configuration in `~/.config/nixos/nix/configuration.nix`.
That flake imports this repository as a local path input and uses its
`homeModules.default` output. `/etc/nixos/configuration.nix` is not imported.

After the first rebuild, `nh` is installed and `NH_FLAKE` points to
`~/.config/nixos`. Open a new shell, then rebuild from any directory:

```sh
nh os switch
```

After changing dotfiles, refresh the local input before switching:

```sh
nix flake update dotfiles --flake ~/.config/nixos
nh os switch
```

On another machine, adjust the host/user settings and dotfiles input path in
`~/.config/nixos`. Version that directory separately from this repository.

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

The system flake's `.envrc` sets `IMPORT_WIN_CA_OUTPUT_FILE` to its `nix/certs/windows-ca.pem`.

Then set this in `~/.config/nixos/nix/configuration.nix` and rebuild:

```nix
security.pki.certificateFiles = [ ./certs/windows-ca.pem ];
```

This is an explicit snapshot, not automatic Windows trust synchronization.
Export again and rebuild after Windows CA changes. Review the trust scope before
importing: the bundle includes intermediate CAs, and Linux does not reproduce
Windows chain/revocation policies. Keep machine-specific exports outside dotfiles;
add them to Git only if the system flake is Git-backed and your policy allows it.
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
on entering the directory. Project secrets go in a project `fnox.toml`
(`fnox exec -- <cmd>`). Python packages with C extensions (psycopg2, gssapi) build on the
host: NixOS's nix-ld supplies their runtime libraries, and `pg_config`/`krb5-config`
are on PATH. uv passes gssapi the krb5 header path it needs
(`nix/modules/home/dev/langs/python.nix`).

## Updating

```sh
nix flake update --flake ~/.config/nixos
nh os switch
```

The current corporate proxy causes GitHub certificate errors. Where direct
access is allowed, fetch inputs without the proxy environment:

```sh
env -u HTTPS_PROXY -u HTTP_PROXY -u https_proxy -u http_proxy -u ALL_PROXY nix flake update --flake ~/.config/nixos
```

Otherwise install your organization's trusted CA; do not disable TLS verification.
Magpie's URL/version/hash are pinned separately in `nix/pkgs/magpie-cli/default.nix`.

## Secrets

`infra` is a **non-flake input** from `github:trent-maetzold/infra/staging`.
`flake.lock` pins its encrypted `secrets.yaml`; this repository does not copy
or migrate the secrets to fnox. Update it explicitly with `nix flake update infra`.

On an existing system without rbw, first enter
`nix shell --inputs-from . nixpkgs#rbw nixpkgs#pinentry-qt` from this checkout.
Fresh installations already have these tools.
Configure rbw for your Bitwarden account (and server URL if self-hosted), then
authenticate locally:

```sh
rbw config set email YOUR_BITWARDEN_EMAIL
rbw config set pinentry pinentry-qt
rbw register
rbw login
rbw unlock
```

The `rbw-agent` user service supplies `SSH_AUTH_SOCK` to shells and user services.
Bitwarden SSH-key items are served through that socket; do not export private
SSH keys to disk. Existing forwarded agent sockets are preserved in SSH sessions.
The desktop Bitwarden app and rbw authenticate separately.

The Bitwarden item **`age-master`** must contain the existing age private key
in its password field. sops retrieves it with `SOPS_AGE_KEY_CMD=rbw get age-master`;
the private key is not written to disk or the Nix store. Home Manager's sops-nix
service decrypts only `shared/codeberg-token` and `shared/deepseek-api-key`, into
user-private runtime files linked under `~/.config/sops-nix/secrets/shared/`.
They are not automatically exported into every process's environment. Other
infra service credentials remain encrypted.

After a reboot, unlock the vault and run
`systemctl --user restart sops-nix.service` (or switch generations) to restore
those runtime files. Locking the vault does **not** revoke already decrypted
files; it blocks subsequent switches and decryptions. The pre-switch check is
not a transaction with user-service activation: if the vault relocks during a
long switch, unlock it and restart the sops service.

To edit secrets, check out `infra` on `staging` and run `sops edit secrets.yaml`
from a new login shell with rbw unlocked. The pinned input in the Nix store is
read-only. Never paste `rbw get age-master` output into a terminal or commit it.

Validate the switch gate without a real vault using `nix build .#checks.x86_64-linux.vault`.

The apps (`import-win-ca`) take each setting from a flag, else an env var, else
an env file (`$ENV_FILE`, default `./.env`); with none set they exit with an error.
