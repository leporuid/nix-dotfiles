{ pkgs, pname, ... }:
let
  inherit (pkgs.lib) licenses optionals;
in
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";
  src = pkgs.fetchFromGitHub {
    owner = "HermesMaker";
    repo = pname;
    rev = "1c999a1cbe17477d04970d3657f6ecfa9478f56f";
    hash = "sha256-x6UCBbeNGbCEZOUGmGOEcDk22PbYBPKm7QWBenef/zI=";
  };
  cargoHash = "sha256-FEpdc9SL8vPP4GW+meEvZSNf7Kjsi1qn0gmpx7nEgu8=";

  # openssl-sys on Linux requires pkg-config and OpenSSL development headers.
  nativeBuildInputs = optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.pkg-config ];
  buildInputs = optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.openssl ];

  meta = {
    description = "Command line interface to convert strings into any case";
    homepage = "https://github.com/HermesMaker/cktool";
    license = licenses.mit;
    mainProgram = pname;
    maintainers = [ ];
  };
}
