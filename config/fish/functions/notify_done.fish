function __notify_long_command --on-event fish_postexec
    if test $CMD_DURATION -gt 10000; and not set -q SSH_TTY
        set -l secs (math $CMD_DURATION / 1000)
        notify-send --app-name=fish "Command finished ($secs""s)" "$argv[1]" 2>/dev/null
    end
end