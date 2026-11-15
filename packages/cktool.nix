{ pkgs, pname, ... }:
with pkgs;
rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";
  src = fetchFromGitHub {
    owner = "HermesMaker";
    repo = pname;
    rev = "1c999a1cbe17477d04970d3657f6ecfa9478f56f";
    hash = "sha256-x6UCBbeNGbCEZOUGmGOEcDk22PbYBPKm7QWBenef/zI=";
  };
  cargoHash = "sha256-FEpdc9SL8vPP4GW+meEvZSNf7Kjsi1qn0gmpx7nEgu8=";

  # openssl-sys on Linux requires pkg-config and OpenSSL development headers.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ openssl ];

  meta = {
    description = "Command line interface to convert strings into any case";
    homepage = "https://github.com/HermesMaker/cktool";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
