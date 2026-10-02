export SWIFTLY_HOME_DIR="$HOME/.swiftly"
export SWIFTLY_BIN_DIR="$HOME/.swiftly/bin"
export SWIFTLY_TOOLCHAINS_DIR="$HOME/Library/Developer/Toolchains"
if [[ ":$PATH:" != *":$SWIFTLY_BIN_DIR:"* ]]; then
    export PATH="$SWIFTLY_BIN_DIR:$PATH"
fi
