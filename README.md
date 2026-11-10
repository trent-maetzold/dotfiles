# NixOS-WSL dotfiles

Host-, user-, and employer-specific settings (hostname, username, git email,
proxy bypass, CLI server URLs) live in the private system flake at
`~/.config/nixos`, not here. `<host>` and `<user>` below stand for them.

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

## Rebuild

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

`just import-windows-ca OUTPUT.pem` (app: `nix run .#import-windows-ca -- OUTPUT.pem`) exports current public CA certificates from the
Windows Current User and Local Machine Root and intermediate stores. It excludes
expired/not-yet-valid and explicitly distrusted certificates, removes duplicates,
and exports no private keys. It requires WSL with Windows interop enabled.

The system flake's `just import-windows-ca` writes `nix/certs/windows-ca.pem` there.

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

Projects use mise (`mise.toml`) for tools and env; mise's shell hook activates it
per directory. Python packages with C extensions (psycopg2, gssapi) build on the
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

`nixosModules.keeper-secrets` writes Keeper vault fields to
`/run/keeper-secrets/<name>` (like agenix/sops-nix), fetched with your Keeper
Commander login. Switch with `just switch` (app: `nix run .#switch`): it logs in
to Keeper if the session expired (and turns on persistent login), then
activation fetches them, and `keeper-secrets.service`
refetches at boot. CLIs read
their file at launch through `pkgs.withSecrets` (`nix/lib/with-secrets.nix`), so
a token reaches only that process. Refetch by hand with `sudo keeper-secrets-sync`.
