# On macOS, login/non-login handoffs pass through /etc/paths and /etc/paths.d,
# which can move Nix profile bin directories behind system paths.
# Prepend active NIX_PROFILES bin directories and deduplicate PATH.
#
# Without the check before executing, the NIX_PROFILES directories will
# always be moved to the front, even when entering a nested `nix develop`
# shell, which could result in the wrong program being executed if specified
# by both the user environment and dev shell.
if test (uname -s) = Darwin; and not set -q __NIX_PROFILES_HAVE_BEEN_MOVED
    for path in (string split ' ' $NIX_PROFILES)
        if test "$path" != "$HOME/.nix-profile"; and test -d "$path/bin"
            set -g PATH $path/bin $PATH
        end
    end

    # Repair PATH if nix-darwin's system profile was somehow skipped
    if not contains -- /run/current-system/sw/bin $PATH
        for fallback_bin in $HOME/.nix-profile/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin
            if test -d $fallback_bin; and not contains -- $fallback_bin $PATH
                set -g PATH $fallback_bin $PATH
            end
        end
    end

    # Deduplicate PATH because it might contain dupes after the handoff from ZSH.
    set -l new_path
    for path in $PATH
        if not contains -- $path $new_path
            set new_path $new_path $path
        end
    end
    set -gx PATH $new_path

    set -gx __NIX_PROFILES_HAVE_BEEN_MOVED 1
end
