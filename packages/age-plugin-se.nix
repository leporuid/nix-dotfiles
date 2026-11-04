{ pkgs, ... }:
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "age-plugin-se";
  version = "0.2.1-unstable-2026-11-02";

  # Allow impure build to access host Xcode SDK and swift compiler
  __noChroot = true;

  src = pkgs.fetchFromGitHub {
    owner = "pr0d1r2";
    repo = "age-plugin-se";
    rev = "6a01275884604dada06d9ec5d84085448841eaca";
    hash = "sha256-wHGNIWcb05S757a3ovTqxLHAtwSeixJexV2+Biuridg=";
  };

  postPatch = ''
    # Remove remote swift-crypto dependency not needed on macOS so swift build runs offline
    substituteInPlace Package.swift \
      --replace-fail '.package(url: "https://github.com/apple/swift-crypto.git", "2.0.0"..<"5.0.0")' "" \
      --replace-fail '.product(
          name: "Crypto", package: "swift-crypto",
          condition: .when(platforms: [.linux, .windows]))' ""
  '';

  buildPhase = ''
    runHook preBuild

    # Resolve host Xcode installation dynamically
    _XCODE_DEV="/Applications/Xcode.app/Contents/Developer"
    if DEVELOPER_DIR= /usr/bin/xcode-select -p &>/dev/null; then
      _SEL=$(DEVELOPER_DIR= /usr/bin/xcode-select -p)
      if [[ "$_SEL" != /nix/* ]] && [ -d "$_SEL" ]; then
        _XCODE_DEV="$_SEL"
      fi
    fi
    export DEVELOPER_DIR="$_XCODE_DEV"
    export SDKROOT="$($_XCODE_DEV/usr/bin/xcrun --sdk macosx --show-sdk-path)"

    /usr/bin/xcrun swift build \
      -c release \
      --disable-sandbox \
      --only-use-versions-from-resolved-file

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 .build/release/age-plugin-se $out/bin/age-plugin-se

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Age plugin for Apple Secure Enclave (built via host Xcode)";
    homepage = "https://github.com/pr0d1r2/age-plugin-se";
    license = licenses.mit;
    mainProgram = "age-plugin-se";
    platforms = platforms.darwin;
  };
})
