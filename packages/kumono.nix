{ pname, pkgs, ... }:
with pkgs;
rustPlatform.buildRustPackage {
  inherit pname;
  version = "master";
  src = pkgs.fetchFromGitHub {
    owner = "APT37";
    repo = pname;
    rev = "master";
    hash = "sha256-ODjpOFkSDmhXwjblS7JqHDVoG0lQyZ/nupUi8peN5m4=";
  };
  cargoHash = "sha256-KOjntRYEVLP4C/LRGljf2Gg90Q+lzFsFZ3ozv2WoNCg=";

  meta = {
    description = "Media ripper for coomer.su and kemono.su";
    homepage = "https://github.com/APT37/kumono";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
