# Bash login-shell initialization.

if [[ -r "$HOME/.bashenv" ]]; then
    source "$HOME/.bashenv"
fi

if [[ -r "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi
