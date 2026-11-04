{ pkgs, ... }:
with pkgs;
stdenv.mkDerivation (finalAttrs: {
  pname = "age-plugin-se";
  version = "0.2.1-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "ink-splatters";
    repo = "age-plugin-se";
    rev = "79522b16a2352c06947ff45a132bb641dcb16132";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    swift
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
  ];

  buildPhase = ''
    runHook preBuild
    swift build -c release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 .build/release/age-plugin-se $out/bin/age-plugin-se
    runHook postInstall
  '';

  meta = with lib; {
    description = "Age plugin for Apple Secure Enclave";
    homepage = "https://github.com/ink-splatters/age-plugin-se";
    license = licenses.mit;
    mainProgram = "age-plugin-se";
    platforms = platforms.darwin;
  };
})
