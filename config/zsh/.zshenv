# Executing hm-session-vars is designed to be idempotent, safe to execute
# multiple times
local session_vars="$HOME/.local/share/zsh/hm-session-vars.sh"
if [[ -f $session_vars && -r $session_vars ]]; then
    source $session_vars
fi

# Prevent non-interactive `zsh -c` invocations (e.g. AI harnesses) from
# failing on Nix flake refs (`#`) or `=` path expansion.
if [[ ! -o interactive ]]; then
    setopt NO_NOMATCH
    unsetopt EQUALS
fi
