# In order to keep ZSH as the login shell but still use
# Fish interactively, this snippet will execute Fish if
# none of the parent processes were Fish. Unless I run into
# some serious issues, I've consolidated on all shells
# launching ZSH, which does some amount of generic init,
# then puts me into Fish if the session is interactive.
#
# zshenv is the first file that ZSH executes, but a standalone
# Home Manager installation adds the Nix setup to zshrc,
# so the necessary setup would be skipped in that system.
# Everything that zshenv does can also be done in zshrc,
# unless it has to be done unconditionally for non-interactive
# shells - in which case that's also the best spot for it,
# since the spawned and exec'd fish shell will inherit
# the variables.
#
# NOTE: this doesn't handle `nix shell` at all because
# it's difficult to determine if the current shell was
# directly invoked by it. Instead, I use a wrapper function
# in Fish that appends `--command $(status fish-path)`.

if [[ -o interactive ]]; then
  if type fish >/dev/null 2>&1; then
    if ! type has-ancestor >/dev/null 2>&1 || ! has-ancestor fish; then
      exec fish -l
    fi
  else
    echo
    echo "  WARNING: fish not found in PATH - falling back to zsh"
    echo
  fi
fi

# Beyond this point, we're setting up ZSH. If Fish doesn't exist on PATH
# then I'll know that by now, so just set things up nicely.

# Let unmatched globs (e.g. Nix flake refs like .#MacBook-Pro) pass through literally
unsetopt nomatch

# Interactive options & macOS-friendly editing defaults (adopted from tw93/Kaku)
setopt interactive_comments
setopt auto_cd auto_pushd pushd_ignore_dups pushdminus
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS HIST_IGNORE_SPACE
setopt SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY EXTENDED_HISTORY
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/.zsh_history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

bindkey -e
# Match macOS Cmd+Backspace line-start deletion instead of killing the whole line
bindkey '^U' backward-kill-line
export CLICOLOR=1

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# Removes duplicates by keeping the first occurrence of each item, left to right.
typeset -U path cdpath fpath manpath

for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

if [[ -d "$HOME/.local/share/mise/shims" ]]; then
  path=("$HOME/.local/share/mise/shims" $path)
fi

## Sheldon fast cached plugin initialization (from azukit-dev/dotfiles)
sheldon_cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon.zsh"
sheldon_toml="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml"
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  if type sheldon >/dev/null 2>&1; then
    sheldon source > "$sheldon_cache"
  fi
fi
[[ -r "$sheldon_cache" ]] && source "$sheldon_cache"
unset sheldon_cache sheldon_toml

# Prefix history search on Up/Down unless another navigator (e.g. atuin) owns ^[[A
if [[ "$(bindkey '^[[A' 2>/dev/null)" == *" up-line-or-history" ]]; then
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  for _zsh_keymap in emacs viins; do
    bindkey -M "$_zsh_keymap" '^[[A' up-line-or-beginning-search
    bindkey -M "$_zsh_keymap" '^[[B' down-line-or-beginning-search
    bindkey -M "$_zsh_keymap" '^[OA' up-line-or-beginning-search
    bindkey -M "$_zsh_keymap" '^[OB' down-line-or-beginning-search
  done
  unset _zsh_keymap
fi

# Cached Starship init (keyed by binary path + mtime) + RPROMPT Ctrl-C fix (from tw93/Kaku)
if (( $+commands[starship] )); then
  _zsh_starship_init_ok=0
  _zsh_starship_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/starship-init.zsh"
  _zsh_starship_key=""
  if zmodload -F zsh/stat b:zstat 2>/dev/null; then
    typeset -a _zsh_starship_stat
    if zstat -A _zsh_starship_stat +mtime -- "${commands[starship]}" 2>/dev/null; then
      _zsh_starship_key="# ${commands[starship]} ${_zsh_starship_stat[1]}"
    fi
    unset _zsh_starship_stat
  fi
  if [[ -n "$_zsh_starship_key" && -r "$_zsh_starship_cache" ]]; then
    _zsh_starship_cache_key=""
    IFS= read -r _zsh_starship_cache_key < "$_zsh_starship_cache" 2>/dev/null
    if [[ "$_zsh_starship_cache_key" == "$_zsh_starship_key" ]]; then
      builtin source "$_zsh_starship_cache"
      _zsh_starship_init_ok=1
    fi
    unset _zsh_starship_cache_key
  fi
  if (( ! _zsh_starship_init_ok )); then
    _zsh_starship_init="$(starship init zsh --print-full-init)"
    if [[ -n "$_zsh_starship_init" ]]; then
      eval "$_zsh_starship_init"
      if [[ -n "$_zsh_starship_key" ]]; then
        command mkdir -p "${_zsh_starship_cache:h}" 2>/dev/null
        if {
          builtin print -r -- "$_zsh_starship_key"
          builtin print -r -- "$_zsh_starship_init"
        } >| "${_zsh_starship_cache}.$$" 2>/dev/null; then
          command mv -f "${_zsh_starship_cache}.$$" "$_zsh_starship_cache" 2>/dev/null \
            || command rm -f "${_zsh_starship_cache}.$$" 2>/dev/null
        fi
      fi
    else
      eval "$(starship init zsh)"
    fi
    unset _zsh_starship_init
  fi
  unset _zsh_starship_init_ok _zsh_starship_cache _zsh_starship_key

  _zsh_render_starship_rprompt() {
    command starship prompt --right \
      --terminal-width="${COLUMNS:-}" \
      --keymap="${KEYMAP:-}" \
      --status="${STARSHIP_CMD_STATUS:-}" \
      --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" \
      --cmd-duration="${STARSHIP_DURATION:-}" \
      --jobs="${STARSHIP_JOBS_COUNT:-0}" 2>/dev/null
  }

  _zsh_fix_starship_rprompt() {
    if [[ "${RPROMPT:-}" == *'$('*'starship'*'prompt --right'* ]]; then
      _zsh_starship_rprompt_cmd="$RPROMPT"
    fi
    if [[ -n "${_zsh_starship_rprompt_cmd:-}" ]]; then
      if [[ "${RPROMPT:-}" == "${_zsh_starship_rprompt_cmd}" ]] || [[ "${RPROMPT:-}" == "${_zsh_last_injected_rprompt:-}" ]]; then
        local evaled
        if [[ "${_zsh_starship_rprompt_cmd}" == *starship*'prompt --right'* ]]; then
          evaled="$(_zsh_render_starship_rprompt)"
        else
          local cmd="${_zsh_starship_rprompt_cmd}"
          if [[ "${cmd[1]}" == '$' && "${cmd[2]}" == '(' && "${cmd[-1]}" == ')' ]]; then
            cmd="${cmd[3,-2]}"
          fi
          evaled="$(eval "$cmd" 2>/dev/null)"
        fi
        RPROMPT="$evaled"
        _zsh_last_injected_rprompt="$evaled"
      fi
    fi
  }
  if [[ ${precmd_functions[(Ie)_zsh_fix_starship_rprompt]} -eq 0 ]]; then
    precmd_functions+=(_zsh_fix_starship_rprompt)
  fi
fi

# Fallback SSH/Mosh TERM normalization for terminals whose terminfo may be missing remotely (from tw93/Kaku)
if ! typeset -f ssh >/dev/null 2>&1 && ! alias ssh >/dev/null 2>&1; then
  function ssh {
    if [[ -z "${ZSH_SSH_SKIP_TERM_FIX:-}" && ( "${TERM:-}" == "xterm-ghostty" || "${TERM:-}" == "kaku" ) ]]; then
      TERM=xterm-256color command ssh "$@"
    else
      command ssh "$@"
    fi
  }
fi

if (( $+commands[mosh] )) && ! typeset -f mosh >/dev/null 2>&1 && ! alias mosh >/dev/null 2>&1; then
  function mosh {
    if [[ -z "${ZSH_SSH_SKIP_TERM_FIX:-}" && ( "${TERM:-}" == "xterm-ghostty" || "${TERM:-}" == "kaku" ) ]]; then
      TERM=xterm-256color command mosh "$@"
    else
      command mosh "$@"
    fi
  }
fi

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
