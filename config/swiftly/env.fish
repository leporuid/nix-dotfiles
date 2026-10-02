set -x SWIFTLY_HOME_DIR "$HOME/.swiftly"
set -x SWIFTLY_BIN_DIR "$HOME/.swiftly/bin"
set -x SWIFTLY_TOOLCHAINS_DIR "$HOME/Library/Developer/Toolchains"
if not contains "$SWIFTLY_BIN_DIR" $PATH
    set -x PATH "$SWIFTLY_BIN_DIR" $PATH
end
