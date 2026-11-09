---
name: developer-workflow
description: Comprehensive developer orchestrator that enforces source-grounding, active context and multimodal inspection, ambient authorization, and auto-synthesizes fast-repo-reader, nix-dotfiles-workflow, tiered-agent-workflow, and get-more-perspectives across all projects. Use whenever working on coding, debugging, inspecting repositories, reviewing developer tasks, or handling attached code, files, or screenshots in ~/Developer.
allowed-tools: client
---

# Developer Workflow

A unified developer orchestration skill that ensures grounded, context-aware, and token-efficient execution across software projects, dotfiles, and system configurations.

## Summary

Enforce a strict "grounding-first, multimodal-aware" standard for all development tasks in `~/Developer`. This skill eliminates hallucinated or context-free answers by prioritizing attached screenshots and files, verifying local repository documentation (`AGENTS.md`, `README.md`, `docs/`), proactively offering to bootstrap guidelines for un-documented projects, and orchestrating specialized sub-skills (`@fast-repo-reader`, `@nix-dotfiles-workflow`, `@tiered-agent-workflow`, `@get-more-perspectives`).

## When to Use

- Starting any coding, debugging, refactoring, or architectural review task in `~/Developer`.
- User provides screenshots of terminal output, error logs, UI mockups, or attached source files.
- Inspecting or modifying dotfiles, Nix flakes, Darwin/NixOS hosts, or custom scripts.
- Evaluating trade-offs between architectural options or researching external GitHub repositories.
- Working on projects lacking clear agent instructions or `AGENTS.md`.

## Core Protocols

### 1. Multimodal & Context-First Invariant

- **Zero-Ignorance Policy**: When the user provides screenshots, images, logs, or attached files, extract and interpret all visible text, stack traces, line numbers, and file paths before formulating a plan.

- **Never Ask for Re-Uploads**: If the user already shared an image or file in the conversation or connected folder, inspect it directly using `client:view_file`. Never ask the user to re-upload or re-type information already provided.

- **Visual Error Triangulation**: Correlate terminal stack traces from screenshots directly with local source files using line numbers and path references.

### 2. Source Grounding & Project Inspection

- **Always Read Ground Truth First**: Before writing or proposing code modifications, inspect the project's root guidance:
  1. Primary: `AGENTS.md` (project conventions, verification commands, invariants).
  2. Secondary: `README.md` and `docs/*.md` (architecture, build steps, dependencies).
  3. Tertiary: Root entrypoints (`flake.nix`, `package.json`, `Cargo.toml`, `go.mod`).

- **No Speculative Coding**: Never guess build commands or project architecture when local documentation exists. Ground every suggested command in the project's verified conventions (e.g. `run switch-host` instead of generic `nixos-rebuild`).

### 3. No-Doc Negotiation & Self-Healing

- If a project directory lacks `AGENTS.md` or clear development guidelines:
  1. Do not proceed with blind, speculative modifications.
  2. Proactively ask the user if they would like to discuss and establish a baseline `AGENTS.md` to persist project expectations and prevent future drift.
  3. Once confirmed, synthesize directory layout, build commands, and testing patterns into a clean `AGENTS.md` following the repository's conventions.

### 4. Ambient Authorization & Frictionless Execution

- **Continuous In-Session Grant**: Once a task is initiated within connected folders (`~/Developer`), treat routine operations (reading files, in-place surgical patches, Git MCP status/diff/staging, local evaluation) as ambiently approved.

- **Suppress Permission Prompts**:
  - Prefer `client:execute_mcp` for Git operations rather than raw terminal commands to avoid sandbox blocks.
  - Do not set `RequiresNetworkAccess: true` unless network operations are strictly necessary.
  - Apply in-place edits using surgical file tools (`replace_file_content`) instead of full file rewrites.
  - Pause for explicit confirmation only on truly destructive or irreversible actions (e.g., `git push --force`, `git reset --hard`, branch deletions).

### 5. Multi-Skill Fusion Matrix

Automatically identify task characteristics and synthesize the relevant sub-skills:

- **Strategic Planning vs. Execution**: Enforce `@tiered-agent-workflow`. Use deep reasoning during Phase 1 (Pro Tier) for context ingestion and diff planning. Switch to minimal-token Phase 2 (Flash Tier) for surgical patches and staging.

- **Nix & System Configurations**: If touching `*.nix`, Darwin, NixOS, or Blueprint configurations, strictly apply `@nix-dotfiles-workflow` rules (never inspect `flake.lock`, enforce single-tier module headers, preserve out-of-store symlinks, and verify with `run check-host` or `nix eval`).

- **External Repository Analysis**: When comparing external GitHub repositories, NUR packages, or upstream flakes, invoke `@fast-repo-reader` to inspect remote trees non-intrusively without terminal network prompts.

- **Architectural Trade-Offs**: When facing divergent implementation paths or significant design decisions, convene the 5-role advisory panel from `@get-more-perspectives` (Operator, Skeptic, Visionary, Customer Advocate, Finance Mind) to assess risks and trade-offs.

## Communication & Verification Standards

- **Language Conventions**: Code comments, commit messages, and variable names must be in clean English. Explanations and user interactions must be in concise Traditional Chinese (Taiwan usage).

- **Verification Before Done**: Run project-specific check commands (e.g. `run check-host`, `nix eval`, test suites) and confirm exit status `0` before declaring completion.

- **Git Hygiene**: Stage only modified target files (`git add <files>`), review `git status --short`, and write concise Conventional Commits.
