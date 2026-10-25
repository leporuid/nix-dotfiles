{ pname, pkgs, ... }:
with pkgs;
rustPlatform.buildRustPackage {
  inherit pname;
  version = "main";

  src = fetchFromGitHub {
    owner = "raviqqe";
    repo = pname;
    rev = "main";
    hash = "sha256-e+fUDVvNg6fHBv7QLWM1xtPon2Ry+XRGUD3EaOipDVY=";
  };

  # FIXME: This should really be removed in favor of using a proper nightly
  # toolchain, but it works for now. Might need to use rust-overlay?
  env.RUSTC_BOOTSTRAP = true;

  cargoHash = "sha256-7OwBx7aA5SUW3tzMUv2g7XrSj//5SWaWexwAcij4o/o=";

  meta = {
    description = "Code formatter for Scheme, Lisp, and any S-expressions";
    homepage = "github.com/raviqqe/schemat";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
