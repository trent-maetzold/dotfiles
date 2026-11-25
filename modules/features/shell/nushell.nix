{
  flake.modules.homeManager.shell-nushell =
    # Settings and nu_scripts setup after github:ryan4yin/nix-config (home/base/core/shells, home/base/tui/shell).
    {pkgs, ...}: {
      programs.nushell = {
        enable = true;
        settings = {
          show_banner = false;
          history = {
            file_format = "sqlite";
            max_size = 5000000;
            isolation = true;
          };
          rm.always_trash = true;
          recursion_limit = 50;
          edit_mode = "vi";
          cursor_shape = {
            emacs = "inherit";
            vi_insert = "block";
            vi_normal = "underscore";
          };
          use_kitty_protocol = false;
          shell_integration = {
            osc2 = true;
            osc7 = true;
            osc8 = true;
            osc9_9 = false;
            osc133 = true;
            osc633 = true;
          };
        };
        extraConfig = ''
          # ryan4yin's helpers (nushell-only: they use nu tables/types).
          def lsa [] { ls -al | table --width 350 }
          def dus [path: string = "."] { du $path | table --width 350 }
          def genpass [length: int = 12] {
            let bytes = (($length * 3 + 2) / 4 | math ceil) + 3
            ^openssl rand -base64 $bytes | str trim | str substring 0..<$length
          }

          # nu_scripts for the kubernetes aliases here and git aliases (dev/git.nix);
          # completions come from carapace (carapace.nix).
          const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${pkgs.nu_scripts}/share/nu_scripts']

          # Prefixed, so argx's `parse` doesn't shadow the builtin (fzf's integration uses it).
          use modules/argx
          use modules/lg
          use modules/kubernetes *

        '';
      };

      # Default for every program's enableNushellIntegration (direnv, fzf, starship, ...).
      home.shell.enableNushellIntegration = true;
    };
}
