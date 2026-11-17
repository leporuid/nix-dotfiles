# AI Agent Credential Guard (`lib/credential-guard.nix`)

## Purpose

Commands executed inside AI coding agents should fail fast instead of hanging on hidden SSH passphrase prompts, unknown host-key confirmations, or Git HTTPS credential prompts.

This repository does **not** use GPG or `gpg-agent` (`age` / `rage` + `age-plugin-se` + SSH keys are used instead), so `lib/credential-guard.nix` provides a lightweight, GPG-free guard built around `agent-askpass-guard`.

## Environment & Wrapping

`agent-askpass-guard` is activated through:

- `SSH_ASKPASS=<store-path>/bin/agent-askpass-guard`
- `SSH_ASKPASS_REQUIRE=force`
- `GIT_ASKPASS=<store-path>/bin/agent-askpass-guard`

In `modules/hjem/agents.nix`:

- `antigravity-cli` (`agy`) is wrapped via `credentialGuard.wrapPackage`, so shell commands spawned by the agent fail fast on interactive prompts.
- `herdr` is intentionally **not** wrapped with `SSH_ASKPASS_REQUIRE=force`, because `herdr` also hosts normal interactive user panes where manual `ssh`, `ssh-add`, `git push`, and `age-plugin-se` operations must remain allowed.

## Agent Recovery Rule

When a command fails with an `AGENT NOTICE:` from `agent-askpass-guard`:

1. **Do not retry** the failing command.
2. Quote the prompt shown in the notice and ask the user to accept the host key, unlock their SSH key (`ssh-add`), or run the command manually.
