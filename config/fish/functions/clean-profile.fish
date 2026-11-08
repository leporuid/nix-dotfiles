function clean-profile -d "Wipe old nix profile generations using nix profile"
    argparse 'd/days=' 'a/all' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: clean-profile [-d|--days <duration>] [-a|--all] [-h|--help]"
        echo
        echo "Options:"
        echo "  -d, --days <duration>  Wipe generations older than duration (default: 7d)"
        echo "  -a, --all              Wipe all non-current generations"
        echo "  -h, --help             Show this help message"
        return 0
    end

    set -l filter_args
    if not set -q _flag_all
        set -l duration "7d"
        if set -q _flag_days
            set duration $_flag_days
            if string match -qr '^\d+$' -- $duration
                set duration "{$duration}d"
            end
        end
        set filter_args --older-than $duration
    end

    # 1. System profile (requires sudo for /nix/var/nix/profiles)
    if test -e /nix/var/nix/profiles/system
        echo (set_color yellow)"==> Wiping system profiles older than "(set -q filter_args[1]; and echo $filter_args[2]; or echo "current")"..."(set_color normal)
        announce sudo nix profile wipe-history --profile /nix/var/nix/profiles/system $filter_args
    end

    # 2. User default profile
    echo (set_color yellow)"==> Wiping user default profile..."(set_color normal)
    announce nix profile wipe-history $filter_args

    # 3. Home Manager profile (if present)
    if test -e $HOME/.local/state/nix/profiles/home-manager
        echo (set_color yellow)"==> Wiping home-manager profile..."(set_color normal)
        announce nix profile wipe-history --profile $HOME/.local/state/nix/profiles/home-manager $filter_args
    end
end
