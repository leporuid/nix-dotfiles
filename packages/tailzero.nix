{ pkgs, ... }:
with pkgs;
let
  version = "v0.2-115-gcd16a55";
  sources = {
    "aarch64-linux" = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-QE6n4HvfWVIaEyWaOfdWRLcKsNLQduiVasRKD0A4hXo="; # Oracle ARM
    };
    "x86_64-linux" = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-9f/YFuHMdwo7mv5Zp6lcmrPEQrdsQFqEmfceZH0kwcI="; # Standard x86_64 Linux
    };
    "aarch64-darwin" = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-cYn4I9a1KF6/9LRppXKmVvkhAfW1rg9qOAa9Bobc6ZE="; # M1/M2/M3 Mac
    };
    "x86_64-darwin" = {
      os = "darwin";
      arch = "amd64";
      hash = "sha256-gD/WsdJmJGr5e1y1auv8Gr7BJE05apvYZdsAt3Qrcho="; # Intel Mac
    };
  };

  system = stdenv.hostPlatform.system;
  sourceInfo = sources.${system} or (throw "Tailzero Unsupported Current Architecture: ${system}");
in
stdenv.mkDerivation {
  pname = "tailzero";
  inherit version;

  src = fetchurl {
    url = "https://tailscale.border0.com/tailzero/stable/tailzero_${version}_${sourceInfo.os}_${sourceInfo.arch}";
    hash = sourceInfo.hash;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/tailzero
    chmod +x $out/bin/tailzero
  '';

  meta = with lib; {
    description = "Border0 Tailzero Connector";
    homepage = "https://border0.com";
    platforms = builtins.attrNames sources;
  };
}
