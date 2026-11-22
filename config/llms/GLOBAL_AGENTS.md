# Global Agent Guide (`leporuid`)

Cross-repository baseline for local coding agents (`agy`, `gcli`, `claude`, `codex`, `opencode`). Repository-local `AGENTS.md` files take precedence inside their respective project trees.

## 1. Language & Communication

- **User Responses**: Concise Traditional Chinese (`zh-Hant-TW`, Taiwan usage). Use British English for general English prose (`GSAT`/`GEKB` exam material excepted).
- **Repository Artifacts**: Write all code comments, skills, docs, and Conventional Commits strictly in clean English.

## 2. Engineering & Verification Discipline

- **Search-First & Narrow Reads**: Locate targets with search tools before reading only required line ranges; patch in place cleanly.
- **Lockfile Hygiene**: Never read or dump lockfiles wholesale (`flake.lock`, `uv.lock`). Inspect metadata commands, manifests (`flake.nix`, `pyproject.toml`, `package.json`), or targeted lines instead.
- **Exit-Code Truthfulness**: Evaluate verification commands strictly by exit code (`$? == 0`); never pipe failing verification checks through `tail` or `head` in a way that masks exit status.
- **Socratic & Tiered Routing**: Use `@socratic` (plus `@get-more-perspectives` for major trade-offs) on architectural forks; keep routine surgical edits fast and direct. Proactively suggest `/model <name>` switches when task complexity shifts.

## Error Handling (Fail-Fast)
- **No Silent Fallbacks**: Never mask failures with bare `try?`/`catch`, `except: pass`, `|| true`, `builtins.tryEval`, or silent defaults (`??`, `or {}`). Always propagate explicit errors, non-zero exit codes, or structured logs (`os.Logger` in Swift extensions).

## 3. Permissions, Workflow & Handover

- **Ambient Repo Authorization**: Routine reads, surgical edits, `git add <target-files>`, local checks, and commits inside active repos proceed without repeated prompts once session approval is granted. Ask explicitly before `git push`, force actions, host activation (`switch`), or deletions outside the repo.
- **Progressive References**: Route skills and the Unified Graph Workflow via `~/.agents/skills/RESOLVER.md`, and consult harness guides (`credential-guard.md`, `nix-architecture.md`) under `~/.gemini/docs/` (`~/.claude/docs/`, `~/.codex/docs/`) on demand.
- **Quota & Context Guard (93%)**: At 93% context/quota, halt new stages, verify completed edits, and record remaining specs into `TODO.md`.
