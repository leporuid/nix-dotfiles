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
    find . -type f -name "N_m3u8DL-RE*" -exec cp {} "$out/bin/N_m3u8DL-RE" \;
    chmod +x "$out/bin/N_m3u8DL-RE"
  '';

  postFixup = (pkgs.callPackage ../m3u8dl-protocol { }).injectHook;
}
