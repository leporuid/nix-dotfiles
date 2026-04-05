{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "master";
  src = pkgs.fetchFromGitHub {
    owner = "APT37";
    repo = pname;
    rev = "master";
    hash = "sha256-AEhLeVxIWb5uMVestaKxZ9HNIVVTh6jkKG8hdrY3/mc=";
  };
  cargoHash = "sha256-nzC+yhDy2kO4cPuxcmaenZ0NXRUbIGVc7Ku2mUdkO30=";

  meta = {
    description = "Media ripper for coomer.su and kemono.su";
    homepage = "https://github.com/APT37/kumono";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}
