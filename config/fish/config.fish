if status is-interactive; and type -q starship
    # Define what the prompt looks like after pressing Enter
    set -g fish_greeting ""
    function starship_transient_prompt_func
        starship module character
    end

    # Initialize Starship normally
    starship init fish | source

    # Enable Starship's native transience (skip in simple terminals)
    if not test -n "$FISH_SIMPLE_TERM"
        enable_transience
    end
end