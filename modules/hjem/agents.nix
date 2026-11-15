{
  config,
  lib,
  perSystem,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.my.programs.agents;
in
{
  options.my.programs.agents = {
    enable = mkEnableOption "AI coding agents, skills, and instruction links via Hjem";
  };

  config = mkIf cfg.enable {
    packages = [
      perSystem.llm-agents.herdr
      perSystem.llm-agents.antigravity-cli
    ];

    my.config.source = {
      ".claude/settings.json" = "claude/settings.json";
      ".agents/skills" = "agents/skills";
      ".claude/skills" = "agents/skills";
      ".gemini/skills" = "gemini/skills";
    };

    # Unified agent instructions distribution across harnesses
    files = {
      ".claude/CLAUDE.md".source = ../../AGENTS.md;
      ".codex/AGENTS.md".source = ../../AGENTS.md;
      ".config/opencode/AGENTS.md".source = ../../AGENTS.md;
    };
  };
}
