{ pkgs, ... }:
with pkgs;
let
  version = "v0.2-101-g4f3c385";
  sources = {
    "aarch64-linux" = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-H2PcspfmvoWt/CU1Tc4J+5+gKCRV2HxIzFdtS5FvJJE="; # Oracle ARM
    };
    "x86_64-linux" = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-YAq6mAbBwXIiYrywowPOT8XjuPIeVh02VjOyZIEqQoE="; # 一般 x86 Linux
    };
    "aarch64-darwin" = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-pWeD40KRs5nPwoh8ukNHD9KcDTcEAy6F7wH1QKnCXtY="; # M1/M2/M3 Mac
    };
    "x86_64-darwin" = {
      os = "darwin";
      arch = "amd64";
      hash = "sha256-EdTHqqXTU0F3bYDWWMj5/3XpER9bfpEW6ynHFRjqp+Q="; # Intel Mac
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