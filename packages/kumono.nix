{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "master";
  src = pkgs.fetchFromGitHub {
    owner = "APT37";
    repo = pname;
    rev = "master";
    hash = "sha256-CD3PmXgV21wzp1+t6MDWoLAeaxb1T4odYbXlT3BHiq0=";
  };
  cargoHash = "sha256-z8qGwE83HdBGcVBofezPH4d/sNFfPD/N7x6CcTAh6M0=";

  meta = {
    description = "Media ripper for coomer.su and kemono.su";
    homepage = "https://github.com/APT37/kumono";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}
