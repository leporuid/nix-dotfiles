# AI Documentation Index (`docs/ai/`)

This directory holds focused, progressive-disclosure reference guides distributed across agent harnesses (`~/.claude/docs`, `~/.codex/docs`, `~/.config/opencode/docs`, `~/.gemini/docs`) via `modules/hjem/agents.nix`.

Keep top-level `AGENTS.md` and `SKILL.md` files concise and consult these guides on demand:

| Guide | Purpose |
| :--- | :--- |
| [nix-architecture.md](./nix-architecture.md) | `red-tape`, `hjem` Manifest v3, `my.config` symlink vs store split, `pedantix.toml`, and verification commands. |
| [credential-guard.md](./credential-guard.md) | Cross-platform SSH/Git askpass guard (`agent-askpass-guard`), `agy`/`herdr` wrapping boundaries, and agent failure recovery. |
