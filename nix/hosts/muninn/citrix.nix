# Citrix on muninn: a 1920x1200 screen (half the panel's resolution), and
# Workspace kept from seeing the NVIDIA GPU. Workspace turns off hardware
# decoding when it finds one, though decoding runs on the Intel GPU, so
# wfica starts in a sandbox whose /dev/dri (read by libdrm) and
# /sys/class/drm list only non-NVIDIA GPUs; everything else (audio, camera,
# USB) is the real system. bwrap
# refuses to run with capabilities, so the CAP_WAKE_ALARM a tty login
# carries is dropped first.
{
  lib,
  pkgs,
  ...
}: {
  imports = [../../modules/nixos/desktop/citrix];

  services.xserver.xrandrHeads = [
    {
      output = "eDP-1";
      primary = true;
      monitorConfig = ''Option "PreferredMode" "1920x1200"'';
    }
  ];

  nixpkgs.overlays = [
    (final: prev: {
      citrix-workspace = prev.citrix-workspace.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            root="$out/opt/citrix-icaclient"
            mv "$root/wfica" "$root/.wfica-real"
            cat > "$root/wfica" <<WRAPPER
            #!${lib.getExe final.bash}
            nvidia=\$(readlink -f /sys/bus/pci/drivers/nvidia/0000:* 2>/dev/null || true)
            args=()
            for e in /sys/class/drm/*; do
              real=\$(readlink -f "\$e")
              for d in \$nvidia; do [[ \$real == "\$d"/* ]] && continue 2; done
              if [[ -L \$e ]]; then
                args+=(--symlink "\$(readlink "\$e")" "\$e")
              else
                args+=(--ro-bind "\$e" "\$e")
              fi
            done
            for e in /dev/dri/card* /dev/dri/renderD*; do
              real=\$(readlink -f "/sys/class/drm/\''${e##*/}")
              for d in \$nvidia; do [[ \$real == "\$d"/* ]] && continue 2; done
              args+=(--dev-bind "\$e" "\$e")
            done
            exec ${final.util-linux}/bin/setpriv --ambient-caps -all ${lib.getExe final.bubblewrap} --dev-bind / / --tmpfs /sys/class/drm --tmpfs /dev/dri "\''${args[@]}" -- "$root/.wfica-real" "\$@"
            WRAPPER
            chmod +x "$root/wfica"
          '';
      });
    })
  ];
}
