# Bash interactive configuration.

# Load environment variables when Bash is started directly as an interactive
# non-login shell.
if [[ -r "$HOME/.bashenv" ]]; then
    source "$HOME/.bashenv"
fi

# Stop here for non-interactive shells.
case "$-" in
    *i*)
        ;;
    *)
        return
        ;;
esac

# Start Fish for interactive Bash sessions.
#
# Bash remains the configured login shell, but interactive sessions are
# replaced by Fish. Non-interactive Bash scripts are unaffected.
if command -v fish >/dev/null 2>&1 &&
   command -v has-ancestor >/dev/null 2>&1 &&
   ! has-ancestor fish; then
    exec fish -l
fi

# Bash history.
export HISTFILE="$HOME/.local/share/bash/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL="ignoreboth:erasedups"

shopt -s histappend
shopt -s cmdhist
shopt -s lithist

# Put mise shims first in PATH when available.
mise_shims="$HOME/.local/share/mise/shims"

if [[ -d "$mise_shims" ]]; then
    case ":$PATH:" in
        *":$mise_shims:"*)
            ;;
        *)
            export PATH="$mise_shims:$PATH"
            ;;
    esac
fi

# Ghostty Bash integration.
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
    ghostty_bash_integration="$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty-integration"

    if [[ -r "$ghostty_bash_integration" ]]; then
        source "$ghostty_bash_integration"
    fi
fi

# Initialize Starship for Bash.
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi