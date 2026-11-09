---
name: tiered-agent-workflow
description: Orchestrates a two-tiered model execution strategy for coding tasks. Dispatches deep-reasoning (Pro tier) for thorough architectural analysis, multi-repo synthesis, and planning, then transitions to token-efficient execution (Flash tier) for in-place patching, git staging, commits, and verification.
---
# Tiered Agent Workflow

Enforces a structured two-tiered execution model that balances deep strategic reasoning with token-efficient mechanical execution.

## When to Use

- Tackling complex architectural changes across Nix configurations, flakes, and dotfiles.
- Evaluating multi-repo patterns (e.g. comparing external configurations before modifying local dotfiles).
- Tasks requiring heavy planning, trade-off evaluation, and structured synthesis before touching code.
- Preventing context bloating during mechanical tasks like file patching, staging (`git add`), and committing.

---

## 1. Phase 1: Strategic Planning & Deep Analysis (Pro Tier)

Before running mutating commands or modifying files, engage deep reasoning:

1. **Context & Trade-Off Analysis**:
   - Ingest reference repositories, issue reports, or system logs.
   - Map external patterns to local constraints (e.g., Numtide Blueprint, Determinate Nix, macOS vs. NixOS).
   - Evaluate edge cases, potential regressions, and evaluation bottlenecks.

2. **Actionable Implementation Plan**:
   - Formulate a concrete, file-by-file patch plan.
   - Specify the exact targets, expected diffs, and validation commands.
   - Do not emit speculative or fragmented code edits during the planning phase.

---

## 2. Phase 2: Token-Efficient Execution (Flash Tier)

Once the plan is settled, switch to streamlined, low-overhead execution:

1. **In-Place File Patching**:
   - Use targeted replacement tools (`replace_file_content`) to apply surgical diffs.
   - Avoid reprinting full files or echoing boilerplate into the conversation.

2. **Git Hygiene & Staging**:
   - Stage only the modified files: `git add <file1> <file2>`.
   - Never use indiscriminate `git add -A` or `git add .` that might capture untracked artifacts.
   - Commit using Conventional Commits with concise, imperative messages.

3. **Validation & Handoff**:
   - Run minimal verification commands (e.g. `git diff --stat`, `nix eval`).
   - Deliver a concise summary of applied changes and actionable next steps.
