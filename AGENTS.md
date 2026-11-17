# Agent Guide (`nix-dotfiles`)

This repository collects project-specific expectations, tool contracts, and architectural guardrails for automated coding agents working across macOS (`nix-darwin`) and Linux (`NixOS`) powered by **`red-tape`**, **`adios-flake`**, **`hjem`**, and **`hjem-rum`**.

---

## 1. Repository Layout

| Directory / File | Description & Purpose |
| :--- | :--- |
| `flake.nix` | Root `red-tape.mkFlake` entrypoint; tracks inputs, system matrix, `flake-schemas` (plus `red-tape.hjemSchemas`), and `overlays.default`. |
| `devshell.nix` | Developer shell toolchain (`mkShellNoCC`: `llm-agents`, `agenix` with `age`, `nixos-rebuild`, `nixos-anywhere`, linters) sourcing `git-hooks.nix`. |
| `formatter.nix` | Root `treefmt-nix` formatter entrypoint delegating to `treefmt.nix`. |
| `treefmt.nix` | Unified formatter and linter rules (`deadnix`, `statix`, `nixfmt`, `fish_indent`, `shfmt`, `taplo`, `yamlfmt`). |
| `pedantix.toml` | Nix code style and argument sorting rules enforced across the repository. |
| `lib/` | Shared Nix helpers (`caches.nix`, `credential-guard.nix`, `darwin.nix`, `nix-settings.nix`). |
| `overlays/` | Nixpkgs overlays (`default.nix`) applied to hosts and exposed via `flake.overlays.default`. |
| `hosts/MacBook-Pro/` | Darwin host configuration (`darwin-configuration.nix`) and user profile bridge. |
| `hosts/nixos/` | Self-contained native NixOS configuration for Oracle Cloud / server (`configuration.nix`). |
| `hosts/nixos-vm/` | Lightweight NixOS VM configuration (imports `modules/nixos` and shared Hjem profile). |
| `modules/darwin/` | Darwin system modules (`aggregate.nix`, `agenix.nix`, `applications.nix`, `system-defaults.nix`, `hjem.nix`, `determinate/`). |
| `modules/nixos/` | NixOS system modules (`aggregate.nix`, `hjem.nix`). |
| `modules/hjem/` | User-level Hjem modules (`aggregate.nix`, `agents.nix`, `my-config.nix`, `themes.nix`, `fish.nix`, `git.nix`, `zsh.nix`, `neovim.nix`, `helix.nix`, `ghostty.nix`, `starship.nix`, `nushell.nix`, `tmux.nix`, `zellij.nix`, `atuin.nix`, `direnv.nix`, `direnv-instant.nix`, `jujutsu.nix`). |
| `modules/common/` | Shared platform configurations (`vars.nix`, `hjem.nix`, `dix.nix`). |
| `packages/*.nix` | Custom derivations and package wrappers consumed via `inputs.self.packages.<system>.<name>`; prefer `lib.fileset.toSource` for clean local source whitelisting. |
| `users/leporuid/` | Shared user profile (`home-configuration.nix`) managing packages and files. |
| `config/` | Raw upstream configurations (`fish/`, `ghostty/`, `nushell/`, `starship.toml`, `git/`, `nvim/`, `agents/`, etc.). |
| `docs/` | Distilled architectural references (`REFERENCE_PATTERNS.md`, `REFER_DEEP_ANALYSIS.md`, `ai/` progressive-disclosure guides). |

---

## 2. Environment & Tooling Contracts

- **Nix Toolchain**: Built with Determinate Nix (`determinateNix` on macOS, `determinate` on NixOS) aligning with the Determinate Nix Reference Manual.
  - **Modern CLI Invariant**: Exclusively use modern Nix 3 CLI commands (`nix profile`, `nix store`, `nix flake`) instead of legacy tools (`nix-env`, `nix-collect-garbage`).
  - **Profile Lifecycle**: Manage profile generations via `nix profile wipe-history [--profile <path>] [--older-than <duration>]`.
  - **Store Management**: Run store garbage collection via `nix store gc --verbose` and hard-link deduplication via `nix store optimise --verbose`.
  - **Build Diagnostics**: Use `nix top` and `nix ps` for active build process inspection and memory monitoring.
  - **Hash & Upgrade Hygiene**: Use `determinate-nixd fix hashes` for fixing mismatched SRI/FOD hashes in Nix expressions. On both macOS (`determinateNix.enable = true`) and NixOS (`determinate.enable = true`), upgrade `determinate-nixd` and Nix declaratively via `nix flake update determinate` and host rebuilds rather than running `sudo determinate-nixd upgrade`.
- **Home Management via Hjem**:
  - Replaces heavy Home Manager with ultra-lightweight `hjem`.
  - **Clobber Invariant**: Always ensure `hjem.clobberByDefault = true;` to avoid collisions with existing files. File overrides use the `clobber` attribute (never deprecated `force`).
  - **No Empty Files**: Hjem modules must never generate empty or placeholder files.
  - **Out-of-Store Symlinks (macOS)**: `my.config.useOutOfStoreSymlinks = isDarwin;` links `config/` directly on macOS for live edits without rebuilds, while keeping Linux hosts on pure Nix store paths.
- **Formatting & Style**:
  - Code formatting is managed via `treefmt` (`nix fmt`).
  - Function argument ordering is strictly enforced by `pedantix.toml`:
    `first = ["self", "inputs", "config", "lib", "pkgs"]`, followed by alphabetical domain args, and `<defaulted>`, `...` last.
- **Verification Matrix & Exit Status Invariant**:
  | Changed Paths | Required Verification Before Commit / Push |
  | :--- | :--- |
  | `*.nix`, `flake.lock`, `hosts/`, `users/`, `modules/`, `packages/` | `nix fmt`, `nix flake check`, and host evaluation check (`darwinConfigurations.MacBook-Pro` & `nixosConfigurations.nixos`) |
  | Only `config/**` (raw dotfiles) | Takes effect immediately on macOS via `useOutOfStoreSymlinks` (no rebuild required) |
  | Newly added / deleted files referenced by Nix expressions | Must run `git add` before evaluating (`nix flake check` requires tracked files) |
  - **Never Mask Exit Codes**: Never pipe verification commands directly into `tail` or `head` without preserving pipeline status. Evaluate success strictly by exit code (`$? == 0`).

---

## 3. Core Architecture Guardrails

- **red-tape Convention**:
  - `red-tape.mkFlake` automatically discovers `hosts/`, `packages/`, `modules/`, `devshell.nix`, and `formatter.nix`.
  - Pass `inherit self inputs;` to `red-tape.mkFlake`.
  - Enable platform modules explicitly:
    ```nix
    modules = [
      inputs.red-tape.modules.redTape.darwin
      inputs.red-tape.modules.redTape.hjem
    ];
    ```
  - Custom nixpkgs overlays live in `overlays/default.nix` and are exposed via `flake.overlays.default`.
  - Module headers must strictly follow `pedantix.toml` argument order.
- **Top-Level Imports**:
  - Never place `imports = [ ... ];` inside a `config = lib.mkIf ... { ... }` block; module imports must always remain at the top level of the module file.
- **Hjem Configuration & Arguments**:
  - Pass flake inputs to Hjem modules via `hjem.specialArgs = { inherit inputs; };`.
  - Custom Hjem program options are located under `my.programs.<program>` (e.g., `my.programs.fish`, `my.programs.ghostty`, `my.programs.starship`, `my.programs.neovim`), while Hjem-Rum modules are under `rum.programs.<program>` (e.g., `rum.programs.git`, `rum.programs.nushell`).
  - **Shell Integration Collision Guard**: Never enable `rum.programs.<tool>.integrations.<shell>.enable = true` if `my.config.source` already manages that shell's main config file (e.g., `fish/config.fish`).
- **Flake Input Hygiene**: Zero out unused transitive inputs (`follows = "";`) to keep `flake.lock` minimal and evaluation fast.
- **Raw Application Configurations (`config/`)**:
  - Keep application configurations directly under root `config/`.
  - Linked via Hjem `files` (`my.config.source`) and managed live on macOS via `my.config.useOutOfStoreSymlinks = isDarwin;`.
  - `config/zsh/.zshrc` handles interactive handoff (`exec fish -l`) and places `unsetopt nomatch` after handoff so flake refs like `.#MacBook-Pro` pass literally in Zsh.
  - Nushell configuration must remain native Nushell syntax in `config/nushell/config.nu` and `config/nushell/env.nu`; do not translate Termius Bash/POSIX injection scripts into compatibility layers.
  - Termius shell integration is client-side input and cannot be disabled or corrected by NixOS or Hjem. Configure Termius separately when it injects Bash/POSIX snippets into Nushell.

---

## 4. Platform Split & Security Model

### macOS (`hosts/MacBook-Pro`)
- Managed by `nix-darwin` + `hjem`.
- **Login Shell & Interactive Shell**: `zsh` (`users.users.${config.system.primaryUser}.shell = pkgs.zsh;`, `UserShell: /run/current-system/sw/bin/zsh`) bootstrapping interactive **Fish** via `config/zsh/.zshrc` (`programs.fish.enable = true;` in `modules/darwin/system-defaults.nix`).
- **Remote Builder**: Builds `aarch64-linux` derivations via `hosts/nixos` (`determinateNix.customSettings.builders = "ssh-ng://leporuid@nixos ..."` with `/etc/ssh/ssh_host_ed25519_key` and `programs.ssh.knownHosts.nixos`).
- **Home Directory**: Explicitly set `directory = "/Users/leporuid";` under `hjem.users.leporuid`.
- **Determinate Daemon**: `nix.enable = false;` with `modules/darwin/determinate/` (`determinateNix.enable = true;`) declaratively managing `determinate-nixd` (copied to `/usr/local/libexec/darwin/` for boot-safe APFS mount), `nix.custom.conf`, `/etc/determinate/config.json`, and `systems.determinate.*` launchd services from `inputs.determinate`.
- **License**: Unfree packages permitted via `nixpkgs.config.allowUnfree = true;`.

### Linux / Server (`hosts/nixos`)
- Managed by `nixos` + `hjem`.
- **Interactive Shell**: `bashInteractive` login shell chaining to `nushell`, with system `programs.fish.enable = true`.
- **Home Directory**: Standard `/home/leporuid`.
- **User Hardening**: `mutableUsers = false`, root password locked, OpenSSH key authentication only.

---

## 5. Agent Workflow & Execution Rules

1. **Mandatory Skills Loading (`agy` & Automated Agents)**:
   - Automated agents (`agy`, Claude, Gemini, Copilot, Cursor) operating in this repository **must** proactively load and strictly adhere to all skills located in `.agents/skills/` (and `config/agents/skills/`).
   - **Before reading, editing, or evaluating any `*.nix`, `flake.lock`, `hosts/`, `modules/`, `packages/`, `users/`, or `config/` path, load `@nix-dotfiles-workflow` first.** Load `@developer-workflow` at the start of every task, and `@tiered-agent-workflow` / `@get-more-perspectives` as the task requires.
   - When a skill and this file disagree, this file wins; update the skill afterwards.
2. **Token Efficiency & Search-First**:
   - Locate targets using `grep_search` or `find_by_name` first.
   - Read only the specific target range (±20 lines) required; never dump whole directories or entire multi-hundred line files into context.
   - **Absolute Ban on Reading `flake.lock`**: Never read or display `flake.lock`. Use `nix flake metadata` for input revisions.
3. **In-Place Patching & Diffs**:
   - Apply edits directly using file edit tools.
   - Explain changes using concise targeted diffs. Never reprint full files in chat responses.
4. **Strict English Code Comments**:
   - All code comments (`#`, `//`, `/* */`) across all Nix expressions, shell scripts, and configuration files must strictly be written in English.
   - Conversation responses to the user should be in concise Traditional Chinese (Taiwan usage).
5. **Session-Level Ambient Authorization & Prompt Suppression**:
   - Once the user grants permission in a session, treat that grant as ambient approval for routine operations within connected folders (reading files, in-place patches, git staging, local evaluations, and commits).
   - Prefer specialized filesystem tools and git MCP tools over raw shell commands to prevent unnecessary permission prompts.
6. **Git Hygiene**:
   - Stage only modified target files (`git add <files>`), review `git status --short`, and write concise Conventional Commits.
7. **Context & Quota Handoff Guard (93% Threshold)**:
   - When session context or model quota usage reaches **93%**, immediately stop starting new stages, verify and checkpoint current edits, and record completed progress plus remaining tasks into `TODO.md` for seamless handoff.

---

## 6. Available Skills & Agent Instructions

Automated agents operating on this repository have access to modular skills located in `config/agents/skills/` (symlinked from `.agents/skills/`):

| Skill | Path | Description & When to Load |
| :--- | :--- | :--- |
| `@developer-workflow` | `.agents/skills/developer-workflow/SKILL.md` | Master orchestrator enforcing source-grounding, active context inspection, and multi-skill execution. |
| `@nix-dotfiles-workflow` | `.agents/skills/nix-dotfiles-workflow/SKILL.md` | Core Nix architecture guardrails (no `flake.lock` reading, `pedantix.toml` module headers, hjem/hjem-rum, `nix-secrets` keys, out-of-store symlinks, verification matrix). |
| `@nix-packaging-and-overlays` | `.agents/skills/nix-packaging-and-overlays/SKILL.md` | Custom derivations (`packages/`, `fileset.toSource`, `pin.json`, `uv2nix`), `overlays/default.nix`, `checks/schemas.nix`, and CI lint compliance. |
| `@darwin-host-and-unifi-dev` | `.agents/skills/darwin-host-and-unifi-dev/SKILL.md` | `hosts/MacBook-Pro`, `modules/darwin/` (`determinateNix`, `mkAppSyncScript`, `nix-homebrew`, `launchd`), and `packages/vpn-pack` UniFi ARM64 cross-builds. |
| `@hjem-module-scaffolder` | `.agents/skills/hjem-module-scaffolder/SKILL.md` | Hjem / Hjem-Rum module boilerplate generator adhering to `pedantix.toml`, RFC 166 `nixfmt`, Manifest v3, and collision guards. |
| `@dotfiles-and-hjem-config` | `.agents/skills/dotfiles-and-hjem-config/SKILL.md` | `my.config` synthesis, `config/` tool setups (`zsh`/`fish`/`nushell`/`nvim`/`helix`/`ghostty`/`jj`), and `check-links` Manifest v3 parity. |
| `@nixos-cloud-deploy` | `.agents/skills/nixos-cloud-deploy/SKILL.md` | Pre-flight evaluation, zero-lockout SSH/Tailscale audit, remote builder, and `nixos-anywhere` / `nixos-rebuild` deployment workflow. |
| `@red-tape-framework-dev` | `.agents/skills/red-tape-framework-dev/SKILL.md` | `~/Developer/red-tape` `adios-flake` DAG, `lib/internal.nix` discovery, `contrib/hjem.nix` Manifest v3, `hjemSchemas`, and offline `nix-unit` tests. |
| `@ktoolbox-fullstack-dev` | `.agents/skills/ktoolbox-fullstack-dev/SKILL.md` | `~/Developer/ktoolbox` (`uv2nix`, FastAPI, `FastMCP`, OpenAPI codegen, React 19/Vite WebUI, `ruff`/`mypy`/`pytest`/`vitest`/`playwright`, `uv-pawchive` rebase). |
| `@nix-secrets-and-enclave` | `.agents/skills/nix-secrets-and-enclave/SKILL.md` | `~/Developer/nix-secrets`, `agenix-rules.nix`, Apple Secure Enclave `age-plugin-se` (`age` vs `rage`), and cross-repo secret hygiene. |
| `@apple-swift-cocoa-dev` | `.agents/skills/apple-swift-cocoa-dev/SKILL.md` | Swift 6.2 SwiftPM (`~/Developer/MyLibrary`, `swiftly`), Xcode MCP, `__noChroot` SDK builds (`age-plugin-se`), and Objective-C Cocoa bundles (`m3u8dl-protocol`). |
| `@gemini-api-dev-bridge` | `.agents/skills/gemini-api-dev-bridge/SKILL.md` | Cross-harness Gemini API dev bridge (`google-genai`/`@google/genai` >= 3.2.0, `gemini-api` CLI dev/CI workflows, `gemini-api-docs` MCP). |
| `@fast-repo-reader` | `.agents/skills/fast-repo-reader/SKILL.md` | Non-intrusive remote inspection of external Git/GitHub repositories without shell network prompts. |
| `@tiered-agent-workflow` | `.agents/skills/tiered-agent-workflow/SKILL.md` | Quota-aware three-phase strategy: Phase 0 Scout (Flash/CLI) $\rightarrow$ Phase 1 Date-Routed Reasoning $\rightarrow$ Phase 2 Builder (Flash). |
| `@get-more-perspectives` | `.agents/skills/get-more-perspectives/SKILL.md` | Simulated 5-role advisory panel for evaluating trade-offs and architecture decisions. |

Agents must consult the relevant `SKILL.md` before executing multi-repo analyses or structural modifications.
