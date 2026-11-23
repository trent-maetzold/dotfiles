# NixOS dotfiles

Every machine is a host in this flake (`nix/hosts/<host>`, wired up in
`flake.nix`), with this repo checked out at `~/.config/dotfiles`. `<host>` and
`<user>` below stand for a host's name and its user.

Development tools are declared in `nix/modules/home/`; language toolchains live in
`nix/modules/home/dev/langs/` with XDG data/cache/state paths. The dotfiles flake uses
`import-tree` to import every module recursively, so new modules need no manual
import entries. Package expressions stay outside that tree in `nix/pkgs/`.
Magpie's pinned CLI is installed everywhere, with the desktop app also available
on Home Manager desktops; Paseo is the daemon/CLI package, not the desktop app. Both run as systemd user services (`magpie.service` and `paseo.service`),
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
| `muninn` | trent's laptop | Umbriel + Noctalia, Home Manager for trent |
| `sif` | Justine's Yoga 720-13IKB | Cinnamon (X11), Flatpak apps via GNOME Software |

### Imported systems

`heimdall` (tailnet gateway) and `yggdrasil` (services and Mimir VM) have
host-local system configurations under `nix/hosts/`. Yggdrasil uses this repo's
non-desktop Home Manager config for `trent`. Its mutable config links expect a checkout
at `/home/trent/.config/dotfiles`. Neither host is supported by `bootstrap`.
Reuse the existing disks and SOPS age keys; do not repartition. After merging,
switch each host to `main` once to install its Comin configuration. Comin will
then stage future builds from `main` for the next reboot, without switching live.

#### Migrating the imported hosts from `tm`

Do not merge or boot the final configuration until the new login is verified on
**both** hosts and any `tm`-owned workloads have an explicit migration plan.
The transitional commit `fb91a575e1d397f780947bf41e879c11dab90ac8`
creates `trent` alongside `tm` without changing the services. From an existing
working `tm` session on each host, switch that commit first (replace `<host>`
with `heimdall` or `yggdrasil`):

```sh
sudo nixos-rebuild switch --flake github:trent-maetzold/dotfiles/fb91a575e1d397f780947bf41e879c11dab90ac8#<host>
```

Keep the original session open and verify a **new** `trent` SSH session, its
key authentication, and `sudo -n true` on each host before proceeding. On
Yggdrasil, prepare `/home/trent/.config/dotfiles` for Home Manager's mutable
links. Check external scripts and SSH aliases too; for example, the homelab
media staging guide and the in-progress secrets CLI have used `tm@10.10.20.10`.

On 2026-11-23 the disposable rootless n8n, Windmill, and Activepieces
containers and their Podman volumes were removed. A stopped `kestra-demo`
container remained; review its disposition and recheck for any other
`tm`-owned workloads, data and subordinate UID/GID mappings before deleting the
account. The final config runs Paseo as `trent`, using `/home/trent/.paseo`
rather than `/home/tm/.paseo`: arrange any needed state migration and verify
the service after switching. Do not blindly change ownership of the whole old
home or rootless container storage. The Hermes dashboard username changes to
`trent`; its Honcho peer also changes to `trent`, which can make existing `tm`
peer-associated memory unavailable until it is migrated.

Only after these checks, switch the final configuration on each host, keeping a
recovery session open, and verify SSH, sudo, Paseo, and the affected workloads.
These hosts use mutable users: removing `tm` from Nix does **not** delete an
existing local account. Once no services, processes, scheduled jobs, or data
still depend on it, end all `tm` sessions and run `sudo userdel tm` on each
host. This does not remove its home; preserve the home and container data until
their disposition has been verified. The
`headscale-remote` wrapper also changes to `trent@hs.trkm.io`, so switch it
only after the new Heimdall login has been tested.

Niðavellir runs on Yggdrasil as a single k3s server with embedded etcd. The
bundled Traefik uses ServiceLB on TCP 80 and 443. For public apps, forward
those ports directly to Yggdrasil; this configuration does not open them in
its host firewall. Do not forward the Kubernetes API port (6443).
The existing trusted tailnet interface is unchanged. To administer the cluster,
SSH to the host and use its local kubeconfig:

```sh
ssh trent@10.10.20.10 'sudo k3s kubectl get nodes'
```

The default `local-path` StorageClass uses `tank/k3s-storage`, mounted at
k3s’s default `/var/lib/rancher/k3s/storage` path. The
`media/nas-data` claim uses Mimir's `/mnt/user/data` NFS export over the
tailnet. Verify the share mounts from a pod and permits the intended writes
before using the claim. The local storage is single-node; back it up off-host.

k3s installs Flux, CloudNativePG, and cert-manager. Flux reads `homelab/main`
at `clusters/nidavellir`. App Ingresses and certificates are managed in Homelab;
add each public DNS record manually, pointing at Yggdrasil's public address
or the router forwarding to it. Heimdall routing is unchanged.

### Laptop installation

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

`nh os switch` builds `github:trent-maetzold/dotfiles/main` for the current
hostname. Use `nh os switch .` to test a local checkout. `just switch` still
updates the local checkout's inputs and commits `flake.lock` before switching.

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

## Citrix (muninn)

Citrix Workspace runs as its own session on **tty8**: Xorg with no compositor,
a kiosk window manager (matchbox) and Workspace, as trent, at 1920x1200 (the
panel scales it). It shares trent's audio, so a Bluetooth headset stays
connected across the switch. **Ctrl+Alt+F8** switches to it and
**Ctrl+Alt+F1** back to Umbriel; every other key, Win and Alt included, goes to
Windows. Umbriel doesn't know about it. The session starts the first time you
switch to tty8 (after the first switch to this config, reboot once so logind
allows tty8) and again after Workspace's X exits; it registers the employer
store if it's missing. Logs: `journalctl -b -u autovt@tty8`.

The vendor files must be in the Nix store before building (accept their
licenses, download them, then for each):

```sh
nix-prefetch-url file://$HOME/Downloads/linuxx64-26.08.0.225.tar.gz
nix-prefetch-url file://$HOME/Downloads/zoomvdi-universal-plugin-ubuntu_7.0.13.deb
```

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
Magpie's CLI and desktop versions and hashes are pinned together in `nix/pkgs/magpie/hashes.json`.

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
