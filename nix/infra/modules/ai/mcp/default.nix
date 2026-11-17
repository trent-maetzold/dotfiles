# MCP servers shared by every agent: Context7, DeepWiki.
{config, ...}: let
  modules.homeManager = {...}: {
    programs.mcp = {
      enable = true;

      servers = {
        context7.url = "https://mcp.context7.com/mcp";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.mcp = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.mcp];
}
