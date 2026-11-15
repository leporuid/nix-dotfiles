# TODO

## ✅ Completed
- CI workflow added, Determinate `nix-eval-jobs` integrated.
- GitHub Actions CI secret handling defined (private `nix-secrets` access).
- `hosts/nixos-vm` user and module imports configured.
- Post‑reboot verification steps passed (experimental features disabled, Ghostty XDG config, Nushell defaults, BAT theme).
- Initial commits (`74380df`, `c310995`) pushed.
- Optional follow‑ups cleared: `accept‑flake‑config` removed, redundant mac‑app‑util input dropped, remote builder trusted, UserShell switched to Zsh with Fish handoff, Zoxide init added.
- CI failures partially addressed: added `nixfmt` to lint step (pending commit), identified hash‑mismatch issue in `packages/comview.nix`.
- Starship profile added for Nushell.
- Archive directories prepared for future cleanup.

## 📋 Pending / Next Session
- **CI**: Verify GitHub Actions CI is configured with `NIX_SECRETS_SSH_KEY` for private `nix-secrets` access.
- **Remote Builder**: Test building `nixosConfigurations.nixos-vm` and `nixosConfigurations.nixos` from MacBook‑Pro via the remote builder.
- **Optional Enhancements**:
  - Add *dix* closure diff (referencing `docs/REFERENCE_PATTERNS.md`).
  - Add `hjemSchemas` unit tests in `red-tape`.
  - After verification, delete archived repositories in `~/Developer/nix-dotfiles-archive` and read references in `~/Developer/refer`.
- **CI Fixes**:
  - Commit addition of `nixpkgs#nixfmt` to the lint step in `.github/workflows/ci.yml`.
  - Resolve hash‑mismatch in `packages/comview.nix` (pin exact revision or update hash).
  - Implement `check-links` for NixOS hosts to compare Hjem generation vs manifest.
- **Starship & Nushell**:
  - Verify Nushell prompt renders correctly after `darwin-rebuild switch`.
  - Delete stale `~/.config/nushell/vendor/autoload/starship.nu` backup.
  - Review `config/nushell/config.nu` for any reverted changes.
- **Uncommitted Work**:
  - Apply pending edits to `config/starship.toml` and `modules/hjem/starship.nix` for Nushell profile.
  - Ensure any new changes are staged and formatted.

## 📌 Notes
- Run `nix fmt` after modifications to keep formatting consistent.
- Use Conventional Commits for any new commits.
