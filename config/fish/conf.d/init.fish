function __source
    # Using type instead of command allows for functions too
    if type -q $argv[1]
        $argv | source
    end
end

__source zoxide init fish
__source direnv hook fish
__source fzf --fish
__source starship init fish --print-full-init

functions -e __source
