{
  config,
  lib,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.my.programs.agents;
  credentialGuard = import ../../lib/credential-guard.nix { inherit pkgs; };
in
{
  options.my.programs.agents = {
    enable = mkEnableOption "AI coding agents, skills, and instruction links via Hjem";
  };

  config = mkIf cfg.enable {
    packages = [
      credentialGuard.askpass
      perSystem.llm-agents.herdr
      (credentialGuard.wrapPackage perSystem.llm-agents.antigravity-cli)
    ];

    my.config.source = {
      ".claude/settings.json" = "claude/settings.json";
      ".agents/skills" = "agents/skills";
      ".claude/skills" = "agents/skills";
      ".gemini/skills" = "agents/skills";
    };

    # Unified agent instructions and progressive-disclosure docs across harnesses
    files = {
      ".claude/CLAUDE.md".source = ../../AGENTS.md;
      ".claude/docs".source = ../../docs/ai;
      ".codex/AGENTS.md".source = ../../AGENTS.md;
      ".codex/docs".source = ../../docs/ai;
      ".config/opencode/AGENTS.md".source = ../../AGENTS.md;
      ".config/opencode/docs".source = ../../docs/ai;
      ".gemini/docs".source = ../../docs/ai;
    };
  };
}
