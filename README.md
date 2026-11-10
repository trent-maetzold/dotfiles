# NixOS-WSL dotfiles

Host-, user-, and employer-specific settings (hostname, username, git email,
proxy bypass, CLI server URLs) live in the private system flake at
`~/.config/nixos`, not here. `<host>` and `<user>` below stand for them.

Development tools are declared in `nix/modules/`; language toolchains live in
`nix/modules/dev/langs/` with XDG data/cache/state paths. The dotfiles flake uses
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

`just import-windows-ca [OUTPUT.pem]` exports current public CA certificates from the
Windows Current User and Local Machine Root and intermediate stores. It excludes
expired/not-yet-valid and explicitly distrusted certificates, removes duplicates,
and exports no private keys. It requires WSL with Windows interop enabled.

By default it writes into the **system** flake, `~/.config/nixos/nix/certs/windows-ca.pem`.

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

`nix/modules/term/tmux.nix` uses `Ctrl-b` as the prefix and follows Herdr's common
bindings: `v`/`-` split, `h/j/k/l` focus panes, Tab/Shift-Tab cycle panes,
`c` creates a tab, `n`/`p` switch tabs, `T` renames a tab, `X` closes a tab,
`x` closes a pane, `z` zooms, and `q` detaches. `r` enters resize mode
(hjkl/arrows; Enter/Escape finishes); `R` reloads the config.
Tmux sessions act as workspaces: `w` opens the picker, `N` creates one,
`W` renames it, and `D` closes it. All these keys follow the prefix.

## Arch build box

NixOS enables rootless Podman. `nix/modules/virt/distrobox.nix` installs Distrobox
and the global `bx` shell alias. `services.podman.builds.arch-build` in
`nix/modules/virt/podman.nix` builds a custom Arch image with the development
packages. Its generated Containerfile uses the host CA bundle during the build
without disabling TLS verification. Distrobox uses the resulting local image,
`localhost/homemanager/arch-build:latest`. Home Manager waits for the build service
to succeed before replacing the box.
Inspect it with `systemctl --user status podman-arch-build-build`.

After rebuilding, run this from your project directory:

```sh
bx uv sync
```

`bx` only enters the existing `arch-build` box; it does not create it.
Commands run in your current directory with the shared home and return to your
host shell when finished. With no arguments, `bx` opens a shell in the box.
The custom image supplies `base-devel`, `postgresql-libs` (libpq headers/`pg_config`),
`krb5` (Kerberos headers/`krb5-config`), `git` and `uv`. The image enables
`UV_SYSTEM_CERTS` and bypasses the proxy for the hosts in `NO_PROXY` (set in the system flake), so
internal package and Git servers are accessed directly. No database/Kerberos services are configured. Arch bundles development files with its libraries; the packages
include libraries too, but only inside the container.

The host CA bundle is mounted read-only at Arch's
`/etc/ca-certificates/extracted/tls-ca-bundle.pem`, which its standard
`/etc/ssl/certs/ca-certificates.crt` symlink uses. Home Manager recreates
`arch-build` on activation (including switches that activate a changed Home Manager
generation). Host CA changes also trigger a new generation so the file mount
resolves the current store path. An unchanged/no-op system switch may skip Home
Manager activation.

**Recreation stops running work and discards container-local files and manually
installed packages.** The shared home directory is preserved. Declare packages
in the Containerfile in `nix/modules/virt/podman.nix`; keep projects in your shared
home. Home Manager rebuilds the image before recreating the box, using Podman's
build cache. This replaces the upstream hash-cached Distrobox service; it does not
recreate containers at login.

Python native extensions built here target Arch, not NixOS. Use the environment
inside the box (e.g. `bx uv run ...`), not as a host-native virtualenv.

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

## Grafana CLI and secrets

`gcx` (Grafana) is in `nix/modules/home.nix`. It is installed only when the
system flake declares the `GRAFANA_SERVICE_ACCOUNT_TOKEN` sops secret, and is
wrapped with `nix/lib/with-secrets.nix`, which reads the decrypted file when
the CLI starts, so the token reaches only that process. `GRAFANA_SERVER` comes
from session variables set in the system flake.
The system flake sets `sops.defaultSopsFile` and the age key.
