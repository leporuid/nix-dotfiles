---
name: nix-dotfiles-workflow
description: Token-efficient workflow and architecture guardrails for Nix, nix-darwin, NixOS, Home Manager, and numtide/blueprint repositories. Use whenever inspecting, editing, debugging, packaging, auditing, or rebuilding Nix configurations, flakes, devshells, or dotfiles.
---
# nix-dotfiles-workflow

## Summary

Enforce a token-minimal, high-precision workflow for maintaining Nix flakes built with `numtide/blueprint` (or `leporuid/blueprint`) and Determinate Nix across macOS (`nix-darwin`) and Linux (`NixOS`).

## When to Use

- Inspecting, auditing, or tracking progress across Nix configuration files (`flake.nix`, `devshell.nix`, `hosts/`, `modules/`, `packages/`, `users/`, `config/`)
- Packaging external CLI tools or custom derivations (e.g., `packages/*.nix` like `n-m3u8dl-re`, `packages/m3u8dl-protocol/`)
- Troubleshooting `nixos-rebuild`, `darwin-rebuild`, `nix flake check`, `nix doctor`, `agenix`, or evaluation failures
- Modifying dotfiles, shell integrations (Bash/Fish/Zsh), or system/home symlinks

---

## 1. Strict Token-Limiting Guardrails (Highest Priority)

1. **Absolute Ban on Reading `flake.lock`**:
   - Never read, display, or inspect `flake.lock` or generated lockfiles into conversation context.
   - If verifying flake inputs or revisions, run `nix flake metadata` or use targeted `grep` for the specific input name.

2. **Truncate Command & Build Outputs**:
   - Any Nix build, eval, check, or rebuild command can produce massive logs or stack traces.
   - Always cap outputs when running or recommending commands: pipe through `2>&1 | tail -n 40` (or `head -n 40`).
   - Never dump full compiler error logs or recursive stack traces into chat.

3. **Search-First, Targeted Inspection (No Whole-Repo Scanning)**:
   - When reviewing or auditing (`完整檢查`, `進度追蹤`), **never** recursively read files or dump entire directories.
   - Use `ripgrep` (`rg`), `grep -rn`, or `ast-grep` to locate target lines first.
   - Read only the specific target range (±15 lines) required for the task.
   - Avoid reading binary, media, or archive files (`.zip`, `.bttpreset`, `.DS_Store`).

4. **In-Place Patching & Diff Edits (No Full-File Dumps)**:
   - Apply edits directly using file replacement/patch tools.
   - In chat responses, explain changes using concise line-level diffs or targeted snippets. Never reprint full files.
   - Eliminate conversational filler: omit meta-announcements ("Here is...", "Sure, I can help...") and present actionable diffs directly.

---

## 2. Core Architecture & Flake Rules

1. **Git Staging Guardrail (`git add`)**:
   - Flakes evaluate ONLY files tracked by Git. Whenever creating or modifying files, remind or stage changes with `git add <file>` before running `nix flake check`, `nix eval`, or rebuilds. Untracked files trigger false-positive evaluation errors.

2. **Blueprint Single-Tier Modules**:
   - Every module under `modules/darwin/`, `modules/nixos/`, `modules/home/`, and `modules/common/` **must** use single-tier module functions:
     ```nix
     { inputs, pkgs, config, lib, vars, ... }: { ... }
     ```
   - Do NOT convert them into two-stage curried headers (`{ inputs, flake, ... }: { config, pkgs, lib, ... }:`).

3. **Import via Flake Outputs**:
   - Import Blueprint modules via `inputs.self.nixosModules.<name>`, `inputs.self.darwinModules.<name>`, or `inputs.self.homeModules.<name>` rather than relative file paths (`../../modules/...`).

4. **Platform & Shell Split**:
   - **macOS (`hosts/MacBook-Pro`)**:
     - Uses `nix-darwin` + Home Manager (`users/leporuid/home-configuration.nix` importing `cloud-configuration.nix`) with `my.config.useOutOfStoreSymlinks = true`.
     - Login shell is Zsh handing off to Fish.
     - Keep `config.system.primaryUser` as the trusted user rather than broad `@admin`.
   - **Oracle NixOS (`hosts/nixos`)**:
     - Uses system-level `modules/nixos/` (`essentials`, `programs`, `tailscale`/`tailzero`) **without** Home Manager.
     - Login shell is `pkgs.bashInteractive` handing off to Fish interactively when a TTY is present and parent process is not Fish (`fish_is_ancestor=0`).
     - Use `nix.settings.trusted-users = [ "root" ];` (never broad `@wheel`).

5. **NixOS vs. Darwin Configuration Differences**:
   - NixOS standard syntax uses `nix.settings.experimental-features = [ ... ]` (do NOT use `extra-experimental-features` under `nix.settings`).
   - Darwin uses `determinateNix.customSettings` where additive `extra-experimental-features` is supported.
   - Shared cache policies live in `modules/common/nix-caches.nix` with clear comments identifying keys.

6. **State Version Safety**:
   - Never set `system.stateVersion` or `home.stateVersion` to future versions (e.g. `26.11`). Maintain the version pinned at host creation (e.g. `25.11` or `24.05`), even when following `nixos-unstable`.

7. **Raw Config Symlinks**:
   - Preserve raw application configurations in `config/` (e.g. `config/fish/`, `config/direnv/`, `config/jj/`) and map them via `my.config.source` (or `my.system.config.source`).
   - Do not rewrite raw files into Nix-generated module options (`programs.<name>.settings`) unless explicitly requested.

---

## 3. Tooling, Packaging & Performance Gotchas

1. **Custom Packaging (`packages/*.nix`) & N_m3u8**:
   - Place custom derivations directly in `packages/<name>.nix` (consumed via `perSystem.self.<name>`) instead of global overlays.
   - For `packages/m3u8dl-protocol/main.m`, maintain native Objective-C compilation for background downloads and system notifications; do not convert to Python scripts.
   - When skipping failing upstream tests (e.g. Agenix checks under rage), use `.overrideAttrs (_: { doCheck = false; doInstallCheck = false; })` with an explanatory English comment.

2. **Fish Completion Optimization**:
   - Never scan `home.packages` to generate completions dynamically (massive evaluation bottleneck). Use an explicit, opt-in `completionPackages` list or built-in Home Manager completions.

3. **Homebrew / Casks Cleanliness**:
   - Keep `HOMEBREW_NO_AUTO_UPDATE = "1"` and `homebrew.onActivation.autoUpdate = false; upgrade = false; cleanup = "none";`.
   - Remove destructive flags like `--force-cleanup` and `--zap` from `extraFlags`.
   - When iterating over `config.homebrew.taps`, handle attribute sets safely (`builtins.attrNames` or extracting `.name`) to prevent `cannot coerce a set to a string`.

4. **Oracle Server & Networking Hardening**:
   - Run Tailzero exclusively on Oracle (`services.tailscale.enable = false`, managed by Tailzero).
   - Never broadcast Oracle metadata IP `169.254.169.254` via Tailscale.
   - Open UDP `41641` for Tailscale direct connections, set SSH `ClientAliveInterval = 60`, and configure Fail2ban to ignore `100.0.0.0/8`.

5. **Devshell & Determinate Nix**:
   - In `devshell.nix`, never add a second `nix` binary to `PATH` (wrap `nixos-rebuild-ng` via `pkgs.writeShellScriptBin` instead of adding `pkgs.nixos-rebuild`).
   - Keep only essential experimental features (`nix-command`, `flakes`, `parallel-eval`), avoiding unstable features like `wasm-builtin` or `pipe-operators`.

---

## 4. Communication & Code Standards

- **Code Comments & Prompts**: All code comments (`#`, `/* */`), terminal output messages, and system notification strings must be written in clean, consistent English.
- **User Explanations**: Provide concise responses in Traditional Chinese (Taiwan usage).
- **Verification First**: Verify changes locally with targeted `nix eval` or `nix flake check` before declaring success.
- **Session-Level Ambient Authorization & Prompt Suppression**:
  - Once the user grants permission ('Allow') at the start of a session or task, treat that grant as ambient approval for all subsequent operations within connected folders (reading files, in-place patches, git staging, local evaluations, and commits) for the remainder of the session without pausing for redundant confirmations.
  - Minimize permission popups: avoid setting `RequiresNetworkAccess: true` unless network is strictly required, prefer specialized filesystem tools and git MCP tools over raw shell commands, and batch related operations into unified turns.
