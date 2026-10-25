{
  pkgs,
  pname ? "m3u8dl-protocol",
  ...
}:

pkgs.stdenv.mkDerivation (finalAttrs: {
  inherit pname;
  version = "1.0.0";

  src = ./.;

  buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    pkgs.apple-sdk
  ];

  buildPhase = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
    $CC -O2 -Wall -Wextra -Wno-unused-parameter \
      -DFFMPEG_BIN_PATH="\"${pkgs.ffmpeg}/bin/ffmpeg\"" \
      -DEXTRA_BIN_PATH="\"${pkgs.lib.makeBinPath [ pkgs.ffmpeg ]}\"" \
      -framework Cocoa \
      main.m -o M3U8DLProtocol
  '';

  installPhase = ''
    mkdir -p "$out/bin"
  ''
  + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
    appDir="$out/Applications/M3U8DLProtocol.app/Contents"
    mkdir -p "$appDir/MacOS"
    cp Info.plist "$appDir/Info.plist"
    cp M3U8DLProtocol "$appDir/MacOS/M3U8DLProtocol"
    ln -s ../Applications/M3U8DLProtocol.app/Contents/MacOS/M3U8DLProtocol "$out/bin/m3u8dl-handler"
    ln -s ../Applications/M3U8DLProtocol.app/Contents/MacOS/M3U8DLProtocol "$out/bin/M3U8DLProtocol"
  '';

  passthru.injectHook = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        mkdir -p "$out/bin" "$out/Applications"
        cp -R "${finalAttrs.finalPackage}/Applications/M3U8DLProtocol.app" "$out/Applications/"
        ln -sf ../Applications/M3U8DLProtocol.app/Contents/MacOS/M3U8DLProtocol "$out/bin/m3u8dl-handler"

        tmpWrapper=$(mktemp)
        cat << 'WRAPPER_HEADER' > "$tmpWrapper"
    STAMP="$HOME/.cache/n-m3u8dl-re/registered_path"
    APP="@APP_PATH@"
    LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
    if [ -f "$LSREGISTER" ] && [ -d "$APP" ]; then
      if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP" 2>/dev/null)" != "$APP" ]; then
        mkdir -p "$(dirname "$STAMP")" 2>/dev/null
        ("$LSREGISTER" -f "$APP" >/dev/null 2>&1 && echo "$APP" > "$STAMP" 2>/dev/null) &
      fi
    fi
    WRAPPER_HEADER
        substituteInPlace "$tmpWrapper" --replace-fail "@APP_PATH@" "$out/Applications/M3U8DLProtocol.app"

        mv "$out/bin/N_m3u8DL-RE" "$out/bin/.N_m3u8DL-RE-bin"
        head -n 1 "$out/bin/.N_m3u8DL-RE-bin" > "$out/bin/N_m3u8DL-RE"
        cat "$tmpWrapper" >> "$out/bin/N_m3u8DL-RE"
        tail -n +2 "$out/bin/.N_m3u8DL-RE-bin" >> "$out/bin/N_m3u8DL-RE"
        rm -f "$tmpWrapper" "$out/bin/.N_m3u8DL-RE-bin"
        chmod +x "$out/bin/N_m3u8DL-RE"
  '';

  meta = with pkgs.lib; {
    description = "Native macOS URL protocol handler (m3u8dl:// and BTT integration) for cat-catch and N_m3u8DL-RE";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.darwin;
    mainProgram = "m3u8dl-handler";
  };
})
