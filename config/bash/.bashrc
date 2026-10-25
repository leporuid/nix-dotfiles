# Bash interactive configuration.

# Load shared environment variables.
if [[ -r "$HOME/.bashenv" ]]; then
    source "$HOME/.bashenv"
fi

# Bash should only continue with interactive configuration when interactive.
case "$-" in
    *i*)
        ;;
    *)
        return
        ;;
esac

# Keep the existing behavior:
# launch Fish for interactive sessions unless:
# - Fish is already an ancestor process
# - the terminal is Warp
# - Fish is unavailable

if [[ "${TERM_PROGRAM:-}" != "WarpTerminal" ]]; then
    if command -v has-ancestor >/dev/null 2>&1 &&
       command -v fish >/dev/null 2>&1 &&
       ! has-ancestor fish; then
        exec fish -l
    elif ! command -v fish >/dev/null 2>&1; then
        printf '\n'
        printf '  WARNING: fish not found in PATH - falling back to bash\n'
        printf '\n'
    fi
fi

# Ghostty Bash integration.
#
# The file may not exist on every system, so check before sourcing it.
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
    ghostty_bash_integration="$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty-integration"

    if [[ -r "$ghostty_bash_integration" ]]; then
        source "$ghostty_bash_integration"
    fi
fi

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

# Initialize Starship for Bash when available.
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# Bash history.
export HISTFILE="$HOME/.local/share/bash/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=20000
