---
name: fast-repo-reader
description: Rapidly analyze and extract architecture, module patterns, and configurations from external GitHub repositories without interactive terminal permission prompts. Use when the user shares a GitHub repository, asks to audit, inspect, or compare an external repo, or wants to extract Nix patterns from repositories like nur-combined.
---
# Fast Repo Reader

Efficiently retrieve, analyze, and synthesize external Git/GitHub repositories by inspecting remote tree structures and targeted files without triggering intrusive host terminal network approval prompts.

## When to Use

- User provides an external GitHub repository (e.g. `github.com/owner/repo`) and asks to read, inspect, or analyze it.
- Comparing external repository architectures (e.g. NUR, flake-parts, dendritic designs) against local dotfiles.
- User requests extracting configurations, packaging recipes, or modules from remote repositories.

## Workflow

1. **Remote Inspection (Non-Intrusive)**:
   - Avoid running ad-hoc `git clone` or terminal `curl` scripts that demand interactive terminal permissions on the user machine.
   - Use web search, GitHub raw content endpoints, or GitHub API trees to fetch repository structure and targeted files directly.

2. **Dendritic Tree & Module Discovery**:
   - Locate root files (`flake.nix`, `README.md`, `default.nix`).
   - Query key directories (`modules/`, `hosts/`, `packages/`, `lib/`).
   - Read only the specific target modules relevant to the user request.

3. **Synthesis & Alignment**:
   - Map discovered patterns to the user's specific architecture (e.g., Numtide Blueprint, Darwin, or NixOS).
   - Evaluate trade-offs before proposing changes, committing to clear recommendations.
