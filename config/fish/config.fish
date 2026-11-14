if status is-interactive
    if test "$TERM" = dumb
        function fish_prompt
            echo '$ '
        end

        function fish_right_prompt
        end
        function fish_greeting
        end
        function fish_title
        end
        return
    end

    # Source interactive integrations
    function __source
        if type -q $argv[1]
            $argv | source
        end
    end
    __source starship init fish
    __source zoxide init fish
    __source direnv hook fish
    __source fzf --fish

    functions -e __source

    if type -q starship
        # Define what the prompt looks like after pressing Enter
        set -g fish_greeting ""
        function starship_transient_prompt_func
            starship module character
        end

        # Enable Starship's native transience (skip in simple terminals)
        if not test -n "$FISH_SIMPLE_TERM"
            enable_transience
        end
    end
end
