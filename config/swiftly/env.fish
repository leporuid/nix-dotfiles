set -gx SWIFTLY_HOME_DIR $HOME/.swiftly
set -gx SWIFTLY_BIN_DIR $SWIFTLY_HOME_DIR/bin
set -gx SWIFTLY_TOOLCHAINS_DIR $HOME/Library/Developer/Toolchains
if test ':'"$PATH"':' != '*'':'"$SWIFTLY_BIN_DIR"':''*'
    set -gx PATH "$SWIFTLY_BIN_DIR"':'"$PATH"
end