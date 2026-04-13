# When used interactively, wraps eza with some nice coloring and good default options.
# When given options or used in a command substitution, delegates to system ls.

function cat
 command bat $argv
        return
    end
