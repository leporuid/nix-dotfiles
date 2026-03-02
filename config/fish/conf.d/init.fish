function __source
    # Using type instead of command allows for functions too
    if type -q $argv[1]
        $argv | source
    end
end

__source starship init fish
__source mise activate fish
__source zoxide init fish
__source direnv hook fish
__source fzf --fish

functions -e __source
