function clean-store -d "Garbage collect and optimise the Nix store using nix store"
    argparse 'p/profiles' 'a/all' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: clean-store [-p|--profiles] [-a|--all] [-h|--help]"
        echo
        echo "Options:"
        echo "  -p, --profiles   Wipe old profile history (7d) before running store GC"
        echo "  -a, --all        Wipe ALL non-current profile history before running store GC"
        echo "  -h, --help       Show this help message"
        return 0
    end

    if set -q _flag_all
        clean-profile --all
        echo
    else if set -q _flag_profiles
        clean-profile
        echo
    end

    echo (set_color green)"==> Running nix store gc..."(set_color normal)
    announce nix store gc --verbose
    echo
    echo (set_color green)"==> Running nix store optimise..."(set_color normal)
    announce nix store optimise --verbose
end
