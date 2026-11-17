# Neovim via LazyVim, with its tools and extras.
{
  config,
  lazyvim,
  ...
}: let
  modules.homeManager = {pkgs, ...}: {
    imports = [lazyvim.homeManagerModules.default];

    programs.neovim.defaultEditor = true;

    programs.lazyvim = {
      enable = true;
      configFiles = ./config;

      extraPackages = with pkgs; [
        ghostscript
        tectonic
        imagemagick
        mermaid-cli
        file
        sqlite
        trash-cli
        tree-sitter
        lua-language-server
        stylua
        lua51Packages.lua
        lua51Packages.luarocks
        llm-agents.copilot-language-server
      ];

      extras = {
        ai = {
          copilot-native.enable = true;
          sidekick.enable = true;
        };

        coding = {
          blink.enable = true;
          mini-comment.enable = true;
          mini-snippets.enable = true;
          mini-surround.enable = true;
          yanky.enable = true;
        };

        dap = {
          core.enable = true;
          nlua.enable = true;
        };

        editor = {
          aerial.enable = true;
          harpoon2.enable = true;
          illuminate.enable = true;
          inc-rename.enable = true;
          mini-files.enable = true;
          overseer.enable = true;
          refactoring.enable = true;
        };

        formatting.prettier.enable = true;
        linting.eslint.enable = true;
        test.core.enable = true;

        ui = {
          smear-cursor.enable = true;
          treesitter-context.enable = true;
        };

        util = {
          dot.enable = true;
          mini-hipatterns.enable = true;
        };
      };

      installCoreDependencies = true;

      treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
        css
        scss
        latex
        svelte
        typst
        vue
      ];
    };

    xdg.configFile."nvim/lua/config/nixpaths.lua".text = ''
      return {
        sqlite3_lib = "${pkgs.sqlite.out}/lib/libsqlite3.so",
      }
    '';
  };
in {
  # Flake Modules
  flake.modules.homeManager.neovim = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.neovim];
}
