function clean-store -d "Clean old system/user profile generations and collect garbage using modern nix commands"
    argparse 'd/days=' 'a/all' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: clean-store [-d|--days <duration>] [-a|--all] [-h|--help]"
        echo
        echo "Options:"
        echo "  -d, --days <duration>  Wipe generations older than duration (default: 7d)"
        echo "  -a, --all              Wipe all non-current generations"
        echo "  -h, --help             Show this help message"
        return 0
    end

    set maybe_sudo
    if test (id -u) -ne 0
        set maybe_sudo sudo
    end

    set -l filter_args
    if not set -q _flag_all
        set -l duration "7d"
        if set -q _flag_days
            set duration $_flag_days
            if string match -qr '^\d+$' -- $duration
                set duration (string join '' $duration 'd')
            end
        end
        set filter_args --older-than $duration
    end

    # 1. System profile generations (requires root permissions for /nix/var/nix/profiles)
    if test -e /nix/var/nix/profiles/system
        echo (set_color yellow)"==> Wiping system profiles"(test (count $filter_args) -gt 0; and echo " ($filter_args)"; or echo " (all non-current)")"..."(set_color normal)
        announce $maybe_sudo nix profile wipe-history --profile /nix/var/nix/profiles/system $filter_args
    end

    # 2. User default profile generations
    echo (set_color yellow)"==> Wiping user default profile"(test (count $filter_args) -gt 0; and echo " ($filter_args)"; or echo " (all non-current)")"..."(set_color normal)
    announce nix profile wipe-history $filter_args

    # 3. Home Manager profile generations (if present)
    if test -e $HOME/.local/state/nix/profiles/home-manager
        echo (set_color yellow)"==> Wiping home-manager profile"(test (count $filter_args) -gt 0; and echo " ($filter_args)"; or echo " (all non-current)")"..."(set_color normal)
        announce nix profile wipe-history --profile $HOME/.local/state/nix/profiles/home-manager $filter_args
    end

    echo
    # 4. Store garbage collection
    echo (set_color green)"==> Running nix store gc..."(set_color normal)
    announce nix store gc --verbose

    echo
    # 5. Store optimisation (deduplicating hard links)
    echo (set_color green)"==> Running nix store optimise..."(set_color normal)
    announce nix store optimise --verbose
end
