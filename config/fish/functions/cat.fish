# Wraps bat while keeping the standard `cat` command name.

function cat
    command bat $argv
    return
end
