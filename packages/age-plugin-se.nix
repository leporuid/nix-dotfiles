{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "age-plugin-se";
  version = "v0.2.1";

  # Allow impure build to access host Xcode SDK and swift compiler
  __noChroot = true;

  src = pkgs.fetchFromGitHub {
    owner = "pr0d1r2";
    repo = "age-plugin-se";
    rev = "main";
    hash = "sha256-+tiZZDr9gr/Dsi+ujaf4LAf8Ar9Bn4zpe2EAgWSxpxY=";
  };

  postPatch = ''
        # Remove Package.resolved to avoid pulling remote dependencies
        rm -f Package.resolved

        cat << 'EOF' > Package.swift
    // swift-tools-version: 6.2
    import PackageDescription

    let package = Package(
      name: "AgeSecureEnclavePlugin",
      platforms: [.macOS("26.0")],
      dependencies: [],
      targets: [
        .executableTarget(
          name: "age-plugin-se",
          dependencies: [],
          path: "Sources",
          exclude: ["SPEC.md", "SPEC-ARCHIVE.md"]
        )
      ]
    )
    EOF
  '';

  buildPhase = ''
    runHook preBuild

    _XCODE_DEV="$(/usr/bin/xcode-select -p 2>/dev/null || true)"

    # Command Line Tools do not contain full Xcode SDK (xcodebuild is full Xcode marker)
    if [ ! -x "$_XCODE_DEV/usr/bin/xcodebuild" ]; then
      _XCODE_DEV="/Applications/Xcode.app/Contents/Developer"
    fi

    if [ ! -x "$_XCODE_DEV/usr/bin/xcodebuild" ]; then
      echo "error: full Xcode installation was not found"
      echo "xcode-select path: $(/usr/bin/xcode-select -p 2>/dev/null || true)"
      exit 1
    fi

    export DEVELOPER_DIR="$_XCODE_DEV"
    export SDKROOT="$(/usr/bin/xcrun --sdk macosx --show-sdk-path)"

    /usr/bin/xcrun swift build \
      -c release \
      --disable-sandbox \
      -Xswiftc -Xfrontend -Xswiftc -disable-availability-checking

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 \
      .build/release/age-plugin-se \
      "$out/bin/age-plugin-se"

    runHook postInstall
  '';

  meta = {
    description = "Age plugin for Apple's Secure Enclave";
    homepage = "https://github.com/pr0d1r2/age-plugin-se";
    license = pkgs.lib.licenses.mit;
    mainProgram = "age-plugin-se";
    platforms = pkgs.lib.platforms.darwin;
  };
}
