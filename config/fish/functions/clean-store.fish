function clean-store -d "Clean old system/user profile generations and collect garbage using modern nix commands"
    argparse 'd/days=' a/all n/dry-run o/optimise optimize h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: clean-store [-d|--days <duration>] [-a|--all] [-n|--dry-run] [-o|--optimise] [-h|--help]"
        echo
        echo "Options:"
        echo "  -d, --days <duration>  Wipe generations older than duration (default: 7d)"
        echo "  -a, --all              Wipe all non-current generations"
        echo "  -n, --dry-run          Preview what will be deleted without changing anything"
        echo "  -o, --optimise         Run deep hardlink deduplication via nix store optimise (slow, opt-in)"
        echo "  -h, --help             Show this help message"
        return 0
    end

    set -l maybe_sudo
    if test (id -u) -ne 0
        set maybe_sudo sudo -H
    end

    set -l filter_args
    if not set -q _flag_all
        set -l duration 7d
        if set -q _flag_days
            set duration $_flag_days
            if string match -qr '^\d+$' -- $duration
                set duration (string join '' $duration 'd')
            end
        end
        set filter_args --older-than $duration
    end

    set -l dry_run_flag
    if set -q _flag_dry_run
        set dry_run_flag --dry-run
    end

    set -l avail_before (df -k / | awk 'NR==2 {print $4}')

    # 1. System profile generations (requires root permissions for /nix/var/nix/profiles)
    if test -e /nix/var/nix/profiles/system
        set -l mode_str (test (count $filter_args) -gt 0; and echo " ($filter_args)"; or echo " (all non-current)")
        if set -q _flag_dry_run
            echo (set_color yellow)"==> [Dry-run] Wiping system profiles"$mode_str"..."(set_color normal)
        else
            echo (set_color yellow)"==> Wiping system profiles"$mode_str"..."(set_color normal)
        end
        announce $maybe_sudo nix profile wipe-history --profile /nix/var/nix/profiles/system $dry_run_flag $filter_args
    end

    # 2. User default profile generations
    set -l user_profile (readlink -f ~/.nix-profile 2>/dev/null; or echo "")
    if test -n "$user_profile" -a -e "$user_profile"
        if set -q _flag_dry_run
            echo (set_color yellow)"==> [Dry-run] Wiping user default profile..."(set_color normal)
        else
            echo (set_color yellow)"==> Wiping user default profile..."(set_color normal)
        end
        announce nix profile wipe-history $dry_run_flag $filter_args
    end

    echo
    # 3. Store garbage collection
    if set -q _flag_dry_run
        echo (set_color green)"==> [Dry-run] Checking store garbage collection..."(set_color normal)
        announce nix store gc --dry-run
    else
        echo (set_color green)"==> Running nix store gc..."(set_color normal)
        announce nix store gc --verbose
    end

    # 4. Store optimisation (deep deduplicating hard links - opt-in)
    if set -q _flag_optimise; or set -q _flag_optimize
        echo
        if set -q _flag_dry_run
            echo (set_color green)"==> [Dry-run] Store optimisation skipped in dry-run mode."(set_color normal)
        else
            echo (set_color green)"==> Running nix store optimise (deep deduplication)..."(set_color normal)
            announce nix store optimise --verbose
        end
    end

    # 5. Space report
    if not set -q _flag_dry_run
        set -l avail_after (df -k / | awk 'NR==2 {print $4}')
        if test -n "$avail_before" -a -n "$avail_after"
            set -l diff_kb (math "$avail_after - $avail_before")
            if test $diff_kb -ge 1048576
                set -l diff_gb (math -s2 "$diff_kb / 1048576")
                echo (set_color cyan)"🎉 Space reclaimed: "$diff_gb" GB"(set_color normal)
            else if test $diff_kb -ge 1024
                set -l diff_mb (math -s1 "$diff_kb / 1024")
                echo (set_color cyan)"🎉 Space reclaimed: "$diff_mb" MB"(set_color normal)
            else if test $diff_kb -gt 0
                echo (set_color cyan)"🎉 Space reclaimed: "$diff_kb" KB"(set_color normal)
            else
                echo (set_color cyan)"✨ Nix store is already clean! (0 B reclaimed)"(set_color normal)
            end
        end
    else
        echo
        echo (set_color yellow)"[Dry-run complete] No changes were made to your system."(set_color normal)
    end
end
