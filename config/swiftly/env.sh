export SWIFTLY_HOME_DIR="/Users/leporuid/.swiftly"
export SWIFTLY_BIN_DIR="/Users/leporuid/.swiftly/bin"
export SWIFTLY_TOOLCHAINS_DIR="/Users/leporuid/Library/Developer/Toolchains"
if [[ ":$PATH:" != *":$SWIFTLY_BIN_DIR:"* ]]; then
    export PATH="$SWIFTLY_BIN_DIR:$PATH"
fi
