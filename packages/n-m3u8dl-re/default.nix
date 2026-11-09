{ pkgs, ... }:
let
  pin = builtins.fromJSON (builtins.readFile ./pin.json);
  hash = if pin.hash != "" then pin.hash else pkgs.lib.fakeHash;
  src = pkgs.fetchzip {
    url = "https://nightly.link/nilaoda/N_m3u8DL-RE/actions/artifacts/${pin.artifactId}.zip";
    inherit hash;
  };
in
pkgs.stdenv.mkDerivation {
  pname = "n-m3u8dl-re";
  version = "actions-${pin.runId}";

  inherit src;

  installPhase = ''
    mkdir -p "$out/bin"
    tarFile=$(find . -maxdepth 2 -type f \( -name "*.tar" -o -name "*.tar.gz" -o -name "*.tgz" \) | head -n 1)
    if [ -n "$tarFile" ]; then
      tar -xf "$tarFile"
    fi
    bin=$(find . -maxdepth 2 -type f ! -name "*.tar*" ! -name "*.zip" -name "*N_m3u8DL-RE*" | head -n 1)
    if [ -z "$bin" ]; then
      echo "Error: N_m3u8DL-RE binary not found after unpacking" >&2
      exit 1
    fi
    cp "$bin" "$out/bin/N_m3u8DL-RE"
    chmod +x "$out/bin/N_m3u8DL-RE"
  '';

  postFixup = (pkgs.callPackage ../m3u8dl-protocol { }).injectHook;
}
