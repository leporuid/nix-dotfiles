#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Tailscale Connection
# @raycast.mode fullOutput
# @raycast.packageName Tailscale
# @raycast.icon 🔗

set -euo pipefail

TAILSCALE_BIN="$(command -v tailscale || true)"
if [[ -z "$TAILSCALE_BIN" ]]; then
    for candidate in /opt/homebrew/bin/tailscale /usr/local/bin/tailscale; do
        if [[ -x "$candidate" ]]; then
            TAILSCALE_BIN="$candidate"
            break
        fi
    done
fi

if [[ -z "$TAILSCALE_BIN" ]]; then
    printf 'tailscale is not available in Raycast'\''s PATH.\n' >&2
    exit 1
fi

if "$TAILSCALE_BIN" status >/dev/null 2>&1; then
    "$TAILSCALE_BIN" down
    printf 'Tailscale disconnected.\n'
else
    "$TAILSCALE_BIN" up
    printf 'Tailscale connected.\n'
fi

"$TAILSCALE_BIN" status 2>&1
