{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";
  src = pkgs.fetchFromGitHub {
    owner = "HermesMaker";
    repo = pname;
    rev = "main";
    hash = "sha256-x6UCBbeNGbCEZOUGmGOEcDk22PbYBPKm7QWBenef/zI=";
  };
  cargoHash = "sha256-FEpdc9SL8vPP4GW+meEvZSNf7Kjsi1qn0gmpx7nEgu8=";

  meta = {
    description = "Command line interface to convert strings into any case";
    homepage = "https://github.com/HermesMaker/cktool";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}
