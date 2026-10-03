{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "N_m3u8DL-RE-bin";

  # 1. UPDATE THIS to the latest version you see on GitHub
  version = "v0.6.0-beta";
  date = "20260629";

  src = fetchurl {
    url = "https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v${version}/N_m3u8DL-RE_v${version}_osx-arm64_${date}.tar.gz";

    # 2. Start with a fake hash to trigger the error that gives you the real one
    hash = "sha256-yhgbfol2Vkdmw0487+SP/0CfWCicqXCt4GJmjAHFORg=";
  };

  sourceRoot = ".";

  # Nix automatically unpacks tar.gz files.
  # We just need to copy the binary to the right place.
  installPhase = ''
    runHook preInstall

    # Create the /bin directory in the Nix store
    mkdir -p $out/bin

    # The file inside the tar is just named "N_m3u8DL-RE"
    install -m755 N_m3u8DL-RE $out/bin/N_m3u8DL-RE

    runHook postInstall
  '';

  meta = with lib; {
    description = "N_m3u8DL-RE (Binary Build)";
    homepage = "https://github.com/nilaoda/N_m3u8DL-RE";
    platforms = [ "aarch64-darwin" ];
  };
}
