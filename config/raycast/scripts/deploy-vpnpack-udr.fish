#!/usr/bin/env fish
# agents: wrapper-only -- delegates to run.fish; no secret handling in this file
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Deploy vpn-pack to UDR
# @raycast.mode fullOutput
# @raycast.packageName nix-dotfiles
# @raycast.icon 🚀
# @raycast.needsConfirmation true

set -l repo "$HOME/Developer/nix-dotfiles"

if not test -d "$repo"
    echo "Repository not found: $repo" >&2
    exit 1
end

if not command -q nix
    echo "Nix is not available in Raycast's PATH." >&2
    exit 1
end

cd "$repo"
or exit 1

exec nix develop --command fish -c '
    source ./run.fish
    or exit 1
    deploy-vpnpack UDR
'
