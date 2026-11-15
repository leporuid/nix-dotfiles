{ pkgs, pname, ... }:
with pkgs;
rustPlatform.buildRustPackage {
  inherit pname;
  version = "master";
  src = pkgs.fetchFromGitHub {
    owner = "APT37";
    repo = pname;
    rev = "9024bc9bee36c9d6ddf97b3516fcdfcf1f124526";
    hash = "sha256-jZquLkvYQz0RM2oJBmMMGJW56/w+yaPnPEdhCvCt1u0=";
  };
  cargoHash = "sha256-4uWdzPK3ER/ckdnIhDHm6FSzWTHr9/dagQ4ZyukJb9w=";

  # aws-lc-sys >= 0.42 is forced onto the system library by cargo-setup-hook (AWS_LC_SYS_USE_SYSTEM=1).
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ aws-lc ];

  meta = {
    description = "Media ripper for coomer.su and kemono.su";
    homepage = "https://github.com/APT37/kumono";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
