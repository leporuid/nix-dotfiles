{ pkgs, ... }:

pkgs.swift.stdenv.mkDerivation (finalAttrs: {
  pname = "age-plugin-se";
  version = "v0.2.1";

  src = pkgs.fetchFromGitHub {
    owner = "pr0d1r2";
    repo = "age-plugin-se";
    rev = "6a01275884604dada06d9ec5d84085448841eaca";
    hash = "sha256-+tiZZDr9gr/Dsi+ujaf4LAf8Ar9Bn4zpe2EAgWSxpxY=";
  };

  # Strip swift-crypto via patch so SwiftPM stays offline with zero external packages on Darwin.
  patches = [ ./darwin-no-swift-crypto.patch ];

  postPatch = ''
    # Remove Package.resolved so SwiftPM does not attempt to resolve unused Linux dependencies
    rm -f Package.resolved
  '';

  nativeBuildInputs = [
    pkgs.swift
    pkgs.swiftpm
  ];

  buildInputs = [
    pkgs.apple-sdk_26
    (pkgs.darwinMinVersionHook "26.0")
  ];

  swiftpmFlags = [
    "-Xcc"
    "-O3"
    "-Xswiftc"
    "-cross-module-optimization"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 \
      "$(swiftpmBinPath)/${finalAttrs.pname}" \
      "$out/bin/${finalAttrs.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Age plugin for Apple's Secure Enclave";
    homepage = "https://github.com/pr0d1r2/age-plugin-se";
    license = pkgs.lib.licenses.mit;
    mainProgram = "age-plugin-se";
    platforms = pkgs.lib.platforms.darwin;
  };
})
