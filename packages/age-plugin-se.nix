{ pkgs, ... }:
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "age-plugin-se";
  version = "0.2.1-unstable-2026-11-02";

  # Allow impure build to access host Xcode SDK and swift compiler
  __noChroot = true;

  src = pkgs.fetchFromGitHub {
    owner = "ink-splatters";
    repo = "age-plugin-se";
    rev = "79522b16a2352c06947ff45a132bb641dcb16132";
    hash = "sha256-wHGNIWcb05S757a3ovTqxLHAtwSeixJexV2+Biuridg=";
  };

  buildPhase = ''
    runHook preBuild

    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    /usr/bin/xcrun swift build -c release --disable-sandbox

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 .build/release/age-plugin-se $out/bin/age-plugin-se

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Age plugin for Apple Secure Enclave (built with host Xcode)";
    homepage = "https://github.com/ink-splatters/age-plugin-se";
    license = licenses.mit;
    mainProgram = "age-plugin-se";
    platforms = platforms.darwin;
  };
})
